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
  rescue StandardError => e
    Rails.logger.error("[AiFactsService] #{e.class}: #{e.message}")
    raise Error, I18n.t('images.ai_facts.generation_failed')
  end

  def ensure_api_key!
    return if ENV['OPENAI_API_KEY'].present?

    raise Error, I18n.t('images.ai_facts.missing_api_key')
  end

  def client
    @client ||= OmniAI::OpenAI::Client.new(
      api_key: ENV.fetch('OPENAI_API_KEY'),
      host: ENV.fetch('OPENAI_HOST', 'https://api.openai.com'),
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
