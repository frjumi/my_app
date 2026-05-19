module WorkImage
  extend ActiveSupport::Concern

  PLACEHOLDER_FILE = 'Винкс.jpeg'.freeze

  # Возвращает хэш с данными изображения темы или nil, если изображение не найдено.
  def show_image(theme_id, image_index)
    theme_images = Image.theme_images(theme_id).to_a
    return nil if theme_images.empty?

    safe_index = image_index % theme_images.size
    one_image = theme_images[safe_index]
    return nil if one_image.blank?

    image_id = one_image.id
    user_id = current_user.id

    user_value = Value.find_by(user_id: user_id, image_id: image_id)
    user_valued = user_value.present? ? 1 : 0
    value = user_value&.value || 0
    common_ave_value = one_image.ave_value || 0

    {
      index: safe_index,
      values_qty: Value.count,
      current_user_id: user_id,
      theme_id: theme_id,
      images_arr_size: theme_images.size,
      image_id: image_id,
      name: one_image.name,
      file: one_image.file,
      user_valued: user_valued,
      value: value,
      common_ave_value: common_ave_value
    }
  end
end
