module ImagesHelper
  # Средняя оценка изображения для отображения в списке
  def image_average_display(image)
    if image.ave_value.present? && image.ave_value.positive?
      number_with_precision(image.ave_value, precision: 2)
    elsif image.values.any?
      number_with_precision(image.values.average(:value), precision: 2)
    else
      t('images.index.no_average')
    end
  end

  # Оценка текущего пользователя для изображения
  def user_rating_display(image, user_ratings)
    rating = user_ratings[image.id]
    rating ? rating.value : t('images.index.no_rating')
  end
end
