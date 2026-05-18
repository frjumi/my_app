class ApplicationController < ActionController::Base
  # ... существующий код

  # Временная заглушка для current_user (возвращает первого пользователя из БД)
  def current_user
    @current_user ||= User.first
  end
  helper_method :current_user   # чтобы метод был доступен в представлениях
end