module WorkImage
  extend ActiveSupport::Concern

  PLACEHOLDER_FILE = 'Винкс.jpeg'.freeze
  IMAGES_PER_PAGE = 1

  # Количество оценок по всем изображениям выбранной темы.
  def theme_values_count(theme_id)
    return 0 if theme_id.blank?

    Value.joins(:image).where(images: { theme_id: theme_id }).count
  end

  # Kaminari: по одному изображению темы на страницу
  def paginated_theme_images(theme_id, page = 1)
    Image.where(theme_id: theme_id).order(:id).page(page).per(IMAGES_PER_PAGE)
  end

  # Данные текущей страницы (изображения) для UI и API
  def show_image(theme_id, page = 1)
    collection = paginated_theme_images(theme_id, page)
    return nil if collection.blank?

    build_image_data(collection, theme_id)
  end

  def build_image_data(collection, theme_id)
    one_image = collection.first
    return nil if one_image.blank?

    image_id = one_image.id
    user_id = current_user.id

    user_value = Value.find_by(user_id: user_id, image_id: image_id)
    user_valued = user_value.present? ? 1 : 0
    value = user_value&.value || 0
    common_ave_value = one_image.ave_value || 0
    image_values_count = Value.where(image_id: image_id).count

    {
      page: collection.current_page,
      total_pages: collection.total_pages,
      first_page: collection.first_page?,
      last_page: collection.last_page?,
      prev_page: collection.prev_page,
      next_page: collection.next_page,
      values_qty: Value.count,
      image_values_count: image_values_count,
      theme_values_count: theme_values_count(theme_id),
      current_user_id: user_id,
      theme_id: theme_id,
      images_arr_size: collection.total_count,
      image_id: image_id,
      name: one_image.name,
      file: one_image.file,
      user_valued: user_valued,
      value: value,
      common_ave_value: common_ave_value,
      paginated_collection: collection
    }
  end
end
