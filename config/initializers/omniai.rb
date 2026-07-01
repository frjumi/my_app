require 'omniai/openai'

# OmniAI читает OPENAI_API_KEY из ENV; host можно переопределить для Ollama/LocalAI.
# .strip убирает \r из CRLF, если .env сохранён в Windows-редакторе.
OmniAI::OpenAI.configure do |config|
  config.api_key = ENV['OPENAI_API_KEY'].to_s.strip.presence if ENV['OPENAI_API_KEY'].present?
  config.host = ENV.fetch('OPENAI_HOST', 'https://api.openai.com').to_s.strip
end
