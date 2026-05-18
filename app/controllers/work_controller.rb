class WorkController < ApplicationController
  before_action :signed_in_user, only: [:index, :choose_theme, :display_theme]

  include WorkImage   # модуль, который мы создадим позже
  include WorkHelper  # хелпер (можно вложить методы напрямую, но для порядка)

  def index
    @images_count = Image.all.count
    @selected_theme = "Select theme to leave your answer"
    @selected_image_name = 'радуга'
    @values_qty = Value.all.count
    @current_locale = I18n.locale
    session[:selected_theme_id] = @selected_theme   # для отображения заглушки
  end

  def choose_theme
    @themes = Theme.all.pluck(:name)
    respond_to :html, :js
  end

  def display_theme
    current_user_id = current_user.id  # позже реализуем аутентификацию, пока заменим на 1 (первый пользователь)
    # временная заглушка:
    current_user_id = 1 if !defined?(current_user)

    if params[:theme].blank? || params[:theme] == "---"
      theme = "Select theme to leave your answer"
      theme_id = 1
      values_qty = Value.all.count.round
      data = { index: 0, name: 'радуга', values_qty: values_qty,
               file: 'Винкс.jpeg', image_id: 4,
               current_user_id: current_user_id, user_valued: false,
               common_ave_value: 0, value: 0 }
    else
      theme = params[:theme]
      theme_id = Theme.find_by(name: theme).id
      data = show_image(theme_id, 0)
    end
    session[:selected_theme_id] = theme_id
    image_data(theme, data)
  end
end