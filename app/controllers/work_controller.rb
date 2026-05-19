class WorkController < ApplicationController
  before_action :signed_in_user, only: [:index, :choose_theme, :display_theme]

  include WorkImage   # модуль, который мы создадим позже
  include WorkHelper  # хелпер (можно вложить методы напрямую, но для порядка)

  def index
    @images_count = Image.all.count
    @selected_theme = t('work.index.select_theme')
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
    if params[:theme].blank? || params[:theme] == "---"
      theme = t('work.index.select_theme')
      theme_id = 1
      values_qty = Value.count
      data = {
        index: 0, name: 'радуга', values_qty: values_qty,
        file: WorkImage::PLACEHOLDER_FILE, image_id: nil,
        current_user_id: current_user.id, user_valued: 0,
        common_ave_value: 0, value: 0, theme_id: theme_id, images_arr_size: 0
      }
    else
      theme = params[:theme]
      theme_id = Theme.find_by(name: theme).id
      data = show_image(theme_id, 0)
    end
    session[:selected_theme_id] = theme_id
    image_data(theme, data)
  end
end