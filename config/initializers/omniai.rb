require 'omniai/openai'

# OmniAI читает OPENAI_API_KEY из ENV; host можно переопределить для Ollama/LocalAI.
OmniAI::OpenAI.configure do |config|
  config.api_key = ENV['OPENAI_API_KEY'] if ENV['OPENAI_API_KEY'].present?
  config.host = ENV.fetch('OPENAI_HOST', 'https://api.openai.com')
end
