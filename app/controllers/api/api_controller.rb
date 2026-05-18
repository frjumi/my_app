module Api
  class ApiController < ApplicationController
    include WorkImage

    # GET /api/next_image?index=0&theme_id=2&length=4
    def next_image
      current_index = params[:index].to_i
      theme_id = params[:theme_id].to_i
      length = params[:length].to_i

      new_image_index = next_index(current_index, length)
      next_image_data = show_image(theme_id, new_image_index)

      respond_to do |format|
        if new_image_index.blank?
          format.json { render json: { error: 'Invalid index' }, status: :unprocessable_entity }
        else
          format.json { render json: {
            new_image_index: next_image_data[:index],
            name: next_image_data[:name],
            file: next_image_data[:file],
            image_id: next_image_data[:image_id],
            user_valued: next_image_data[:user_valued],
            common_ave_value: next_image_data[:common_ave_value],
            value: next_image_data[:value],
            status: 'success',
            notice: 'Successfully moved to next image'
          } }
        end
      end
    end

    # GET /api/prev_image?index=0&theme_id=2&length=4
    def prev_image
      current_index = params[:index].to_i
      theme_id = params[:theme_id].to_i
      length = params[:length].to_i

      new_image_index = prev_index(current_index, length)
      prev_image_data = show_image(theme_id, new_image_index)

      respond_to do |format|
        if new_image_index.blank?
          format.json { render json: { error: 'Invalid index' }, status: :unprocessable_entity }
        else
          format.json { render json: {
            new_image_index: prev_image_data[:index],
            name: prev_image_data[:name],
            file: prev_image_data[:file],
            image_id: prev_image_data[:image_id],
            user_valued: prev_image_data[:user_valued],
            common_ave_value: prev_image_data[:common_ave_value],
            value: prev_image_data[:value],
            status: 'success',
            notice: 'Successfully moved to previous image'
          } }
        end
      end
    end

    private

    # Определяем следующий индекс (с зацикливанием)
    def next_index(index, length)
      return 0 if length <= 1
      (index + 1) % length
    end

    # Определяем предыдущий индекс (с зацикливанием)
    def prev_index(index, length)
      return 0 if length <= 1
      (index - 1 + length) % length
    end
  end
end