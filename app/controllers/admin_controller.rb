class AdminController < ApplicationController
  # Отключаем защиту от CSRF для этого экшена (т.к. это не форма, а запрос из curl)
  skip_before_action :verify_authenticity_token, only: [:run_seed]

  # HTTP Basic Auth (если нужно) – это МЕТОД КЛАССА, вызывается один раз
  http_basic_authenticate_with name: ENV['ADMIN_NAME'], password: ENV['ADMIN_PASSWORD'] if ENV['ADMIN_NAME']

  def run_seed
    # Проверка токена (простая, но эффективная)
    if params[:token] == ENV['SEED_TOKEN']
      # Запускаем seed
      system("cd #{Rails.root} && bundle exec rake db:seed RAILS_ENV=production")
      render plain: "Seed executed successfully"
    else
      render plain: "Unauthorized", status: :unauthorized
    end
  end
end