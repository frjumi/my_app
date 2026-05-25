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
    @themes = Theme.where.not(name: '---').order(:id).pluck(:name)
    respond_to :html, :js
  end

  def display_theme
    if params[:theme].blank? || params[:theme] == '---'
      theme = t('work.index.select_theme')
      data = idle_theme_data
      session[:selected_theme_id] = nil
    else
      theme = params[:theme]
      theme_record = Theme.find_by(name: theme)

      unless theme_record
        theme = t('work.index.select_theme')
        data = idle_theme_data
        session[:selected_theme_id] = nil
      else
        theme_id = theme_record.id
        @paginated_images = paginated_theme_images(theme_id, 1)
        data = show_image(theme_id, 1)
        data = fallback_theme_data(theme_record) if data.nil?
        data[:idle] = false
        session[:selected_theme_id] = theme_id
      end
    end

    image_data(theme, data)
    respond_to :js
  end

  private

  def idle_theme_data
    {
      values_qty: Value.count,
      file: WorkImage::PLACEHOLDER_FILE,
      image_id: nil,
      name: nil,
      current_user_id: current_user.id,
      user_valued: 0,
      common_ave_value: 0,
      value: 0,
      theme_id: nil,
      images_arr_size: 0,
      image_values_count: 0,
      theme_values_count: 0,
      page: 1,
      total_pages: 0,
      first_page: true,
      last_page: true,
      idle: true
    }
  end

  # Данные, когда тема выбрана, но изображений в БД для неё нет (часто на проде без seed)
  def fallback_theme_data(theme_record)
    theme_id = theme_record.id
    {
      values_qty: Value.count,
      file: WorkImage::PLACEHOLDER_FILE,
      image_id: nil,
      name: t('work.index.no_images_in_theme'),
      current_user_id: current_user.id,
      user_valued: 0,
      common_ave_value: 0,
      value: 0,
      theme_id: theme_id,
      images_arr_size: 0,
      image_values_count: 0,
      theme_values_count: theme_values_count(theme_id),
      page: 1,
      total_pages: 0,
      first_page: true,
      last_page: true,
      idle: false,
      no_images: true
    }
  end
end
