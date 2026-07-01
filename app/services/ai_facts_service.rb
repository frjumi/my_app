# frozen_string_literal: true

require 'omniai/openai'

# Генерация и кэширование текста «интересные факты» для изображения (один раз на запись).
class AiFactsService
  class Error < StandardError; end

  def self.call(image)
    new(image).call
  end

  def initialize(image)
    @image = image
  end

  # Возвращает сохранённый или только что сгенерированный текст.
  def call
    return image.ai_fact if image.ai_fact.present?

    image.with_lock do
      image.reload
      return image.ai_fact if image.ai_fact.present?

      text = request_fact_from_llm
      image.update!(ai_fact: text)
      text
    end
  end

  private

  attr_reader :image

  def request_fact_from_llm
    ensure_api_key!

    response = client.chat do |prompt|
      prompt.system system_instruction
      prompt.user user_prompt
    end

    text = response.text.to_s.strip
    raise Error, I18n.t('images.ai_facts.empty_response') if text.blank?

    text
  rescue Error
    raise
  rescue OmniAI::HTTPError => e
    Rails.logger.error("[AiFactsService] #{e.class}: #{e.message}")
    raise Error, api_error_message(e)
  rescue StandardError => e
    Rails.logger.error("[AiFactsService] #{e.class}: #{e.message}")
    raise Error, I18n.t('images.ai_facts.generation_failed')
  end

  def api_error_message(error)
    message = error.message.to_s

    if message.include?('insufficient_quota')
      return I18n.t('images.ai_facts.insufficient_quota')
    end
    if message.include?('status=429')
      return I18n.t('images.ai_facts.rate_limited')
    end
    if message.include?('status=401')
      return I18n.t('images.ai_facts.invalid_api_key')
    end

    I18n.t('images.ai_facts.generation_failed')
  end

  def ensure_api_key!
    return if openai_api_key.present?

    raise Error, I18n.t('images.ai_facts.missing_api_key')
  end

  def openai_api_key
    @openai_api_key ||= ENV['OPENAI_API_KEY'].to_s.strip.presence
  end

  def openai_host
    ENV.fetch('OPENAI_HOST', 'https://api.openai.com').to_s.strip
  end

  def client
    @client ||= OmniAI::OpenAI::Client.new(
      api_key: openai_api_key,
      host: openai_host,
      timeout: 60
    )
  end

  def system_instruction
    'Ты пишешь короткие познавательные тексты о вселенной Winx Club для широкой аудитории.'
  end

  def user_prompt
    <<~TEXT.strip
      Персонаж и превращение: #{image.name}.

      Напиши небольшой интересный рассказ об этом превращении.
      Требования:
      - объём примерно 100–150 слов;
      - только проверенные общеизвестные факты из канона Winx Club;
      - никаких вымышленных историй;
      - не используй Markdown;
      - обычный текст;
      - пиши интересно и понятным языком;
      - не перечисляй факты списком;
      - оформи ответ как один связный абзац.
    TEXT
  end
end
