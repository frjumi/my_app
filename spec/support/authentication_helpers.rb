# frozen_string_literal: true

module AuthenticationHelpers
  # Вход пользователя через remember_token (как в SessionsHelper)
  def sign_in(user)
    token = User.new_remember_token
    user.update_column(:remember_token, User.encrypt(token))
    cookies[:remember_token] = token
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end
