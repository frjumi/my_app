module Api
  class ApiController < ApplicationController
    include WorkImage

    before_action :signed_in_user

    # GET /api/next_image?index=0&theme_id=2&length=4
    def next_image
      render_navigated_image(:next)
    end

    # GET /api/prev_image?index=0&theme_id=2&length=4
    def prev_image
      render_navigated_image(:prev)
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

    def render_navigated_image(direction)
      current_index = params[:index].to_i
      theme_id = params[:theme_id].to_i
      length = params[:length].to_i

      new_index = direction == :next ? next_index(current_index, length) : prev_index(current_index, length)
      image_data = show_image(theme_id, new_index)

      if image_data.nil?
        render json: { status: 'error', error: I18n.t('api.navigation.image_not_found') }, status: :not_found
        return
      end

      notice_key = direction == :next ? 'api.navigation.next_success' : 'api.navigation.prev_success'
      render json: image_json_payload(image_data).merge(
        new_image_index: image_data[:index],
        notice: I18n.t(notice_key)
      )
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
        status: 'success'
      }
    end

    def picture_asset_url(filename)
      view_context.asset_path("pictures/#{filename}")
    end

    def next_index(index, length)
      return 0 if length <= 1

      (index + 1) % length
    end

    def prev_index(index, length)
      return 0 if length <= 1

      (index - 1 + length) % length
    end
  end
end
