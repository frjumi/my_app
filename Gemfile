source "https://rubygems.org"
ruby "3.3.6"

# Основные гемы (доступны везде)
gem "rails", "~> 7.1.2"
gem "sprockets-rails"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "turbolinks", "~> 5.2"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "bootsnap", require: false

# Шаблонизатор Haml – обязательно для production
gem 'haml-rails', '~> 2.0'

# Стили
gem 'sassc-rails'
gem 'jquery-rails'
gem 'bootstrap-sass', '~> 3.4.1'
gem 'font-awesome-sass', '~> 6.0'
gem 'kaminari'
gem 'jquery-ui-rails'
gem 'bcrypt', '~> 3.1.7'
gem 'activerecord-reset-pk-sequence'
gem 'active_model_serializers'

# LLM: интересные факты о превращениях Winx (OmniAI + OpenAI)
gem 'omniai'
gem 'omniai-openai'

group :development, :test do
  gem 'dotenv-rails'
  gem "debug", platforms: %i[mri windows]
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'html2haml'   # только для конвертации
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails'
end

group :development do
  gem "web-console"
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem 'simplecov', require: false
end