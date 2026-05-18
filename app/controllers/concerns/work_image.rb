module WorkImage
  extend ActiveSupport::Concern

  def show_image(theme_id, image_index)
    theme_images = Image.theme_images(theme_id)
    current_user_id = 1  # временно, пока нет auth

    one_image_attr = theme_images[image_index].attributes
    image_id = one_image_attr["id"]

    # Проверка, оценивал ли текущий пользователь это изображение
    user_valued = Value.exists?(user_id: current_user_id, image_id: image_id) ? 1 : 0
    value = user_valued == 1 ? Value.find_by(user_id: current_user_id, image_id: image_id).value : 0

    values_qty = Value.all.count

    if user_valued == 1
      common_ave_value = Image.find(image_id).ave_value || 0
    else
      common_ave_value = 0
    end

    data = {
      index: image_index,
      values_qty: values_qty,
      current_user_id: current_user_id,
      theme_id: theme_id,
      images_arr_size: theme_images.size,
      image_id: image_id,
      name: one_image_attr["name"],
      file: one_image_attr["file"],
      user_valued: user_valued,
      value: value,
      common_ave_value: common_ave_value
    }
    data
  end
end