class WorkController < ApplicationController
  before_action :signed_in_user, only: [:index, :choose_theme, :display_theme]

  include WorkImage
  include WorkHelper

  def index
    @selected_theme = t('work.index.select_theme')
    @values_qty = Value.count
    @theme_values_count = 0
    @current_locale = I18n.locale
    session[:selected_theme_id] = nil
  end

  def choose_theme
    @themes = Theme.all.pluck(:name)
    respond_to :html, :js
  end

  def display_theme
    if params[:theme].blank? || params[:theme] == '---'
      theme = t('work.index.select_theme')
      values_qty = Value.count
      data = {
        index: 0,
        values_qty: values_qty,
        file: WorkImage::PLACEHOLDER_FILE,
        image_id: nil,
        current_user_id: current_user.id,
        user_valued: 0,
        common_ave_value: 0,
        value: 0,
        theme_id: nil,
        images_arr_size: 0,
        image_values_count: 0,
        theme_values_count: 0,
        idle: true
      }
      session[:selected_theme_id] = nil
    else
      theme = params[:theme]
      theme_record = Theme.find_by(name: theme)
      theme_id = theme_record.id
      data = show_image(theme_id, 0)
      data[:idle] = false
      session[:selected_theme_id] = theme_id
    end
    image_data(theme, data)
  end
end
