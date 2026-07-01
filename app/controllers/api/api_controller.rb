module Api
  class ApiController < ApplicationController
    include WorkImage

    before_action :signed_in_user

    # GET /api/next_image?theme_id=2&page=1 — следующая страница Kaminari
    def next_image
      render_paginated_image(:next)
    end

    # GET /api/prev_image?theme_id=2&page=2 — предыдущая страница Kaminari
    def prev_image
      render_paginated_image(:prev)
    end

    # POST /api/ai_fact — интересные факты (генерация один раз, далее из БД)
    def ai_fact
      image = Image.find(params[:image_id])
      was_cached = image.ai_fact.present?
      text = AiFactsService.call(image)

      render json: {
        status: 'success',
        ai_fact: text,
        cached: was_cached,
        image_id: image.id
      }
    rescue AiFactsService::Error => e
      render json: { status: 'error', error: e.message }, status: :unprocessable_entity
    rescue ActiveRecord::RecordNotFound
      render json: { status: 'error', error: I18n.t('api.rate_image.image_not_found') }, status: :not_found
    end

    # POST /api/rate_image — создание или обновление оценки текущего пользователя
    def rate_image
      image = Image.find(params[:image_id])
      rating = params[:value].to_i
      value_record = current_user.values.find_or_initialize_by(image_id: image.id)
      is_new_record = value_record.new_record?
      value_record.value = rating

      if value_record.save
        image.recalculate_ave_value!
        image.reload
        message_key = is_new_record ? 'api.rate_image.created' : 'api.rate_image.updated'

        render json: {
          status: 'success',
          message: I18n.t(message_key),
          new_average: image.ave_value,
          new_total_values: image.values.count,
          theme_values_count: theme_values_count(image.theme_id),
          common_ave_value: image.ave_value,
          user_value: value_record.value,
          user_valued: true,
          updated: !is_new_record
        }
      else
        render json: {
          status: 'error',
          errors: value_record.errors.full_messages
        }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { status: 'error', error: I18n.t('api.rate_image.image_not_found') }, status: :not_found
    end

    private

    def render_paginated_image(direction)
      theme_id = params[:theme_id].to_i
      current_page = [params[:page].to_i, 1].max

      collection = paginated_theme_images(theme_id, current_page)
      if collection.blank?
        render json: { status: 'error', error: I18n.t('api.navigation.image_not_found') }, status: :not_found
        return
      end

      target_page = direction == :next ? collection.next_page : collection.prev_page

      unless target_page
        error_key = direction == :next ? 'api.navigation.last_page' : 'api.navigation.first_page'
        render json: { status: 'error', error: I18n.t(error_key) }, status: :unprocessable_entity
        return
      end

      new_collection = paginated_theme_images(theme_id, target_page)
      image_data = build_image_data(new_collection, theme_id)

      notice_key = direction == :next ? 'api.navigation.next_success' : 'api.navigation.prev_success'
      render json: image_json_payload(image_data).merge(notice: I18n.t(notice_key))
    end

    def image_json_payload(image_data)
      {
        name: image_data[:name],
        file: image_data[:file],
        image_url: picture_asset_url(image_data[:file]),
        placeholder_url: picture_asset_url(WorkImage::PLACEHOLDER_FILE),
        image_id: image_data[:image_id],
        user_valued: image_data[:user_valued],
        common_ave_value: image_data[:common_ave_value],
        new_average: image_data[:common_ave_value],
        value: image_data[:value],
        user_value: image_data[:value],
        new_total_values: image_data[:image_values_count],
        image_values_count: image_data[:image_values_count],
        theme_values_count: image_data[:theme_values_count],
        current_page: image_data[:page],
        total_pages: image_data[:total_pages],
        first_page: image_data[:first_page],
        last_page: image_data[:last_page],
        prev_page: image_data[:prev_page],
        next_page: image_data[:next_page],
        ai_fact: image_data[:ai_fact],
        status: 'success'
      }
    end

    def picture_asset_url(filename)
      view_context.asset_path("pictures/#{filename}")
    end
  end
end
