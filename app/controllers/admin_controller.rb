class AdminController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:run_seed]
  before_action :authenticate_admin

  def run_seed
    if params[:token] == ENV['SEED_TOKEN']
      system("bundle exec rake db:seed RAILS_ENV=production")
      render plain: "Seed executed successfully"
    else
      render plain: "Unauthorized", status: :unauthorized
    end
  end

  private

  def authenticate_admin
    # Дополнительная защита: проверка IP или HTTP Basic Auth
    http_basic_authenticate_with name: ENV['ADMIN_NAME'], password: ENV['ADMIN_PASSWORD'] if ENV['ADMIN_NAME']
  end
end