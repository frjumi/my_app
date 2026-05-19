module ValuesHelper
  def value_image_average(value)
    image = value.image
    if image.ave_value.present? && image.ave_value.positive?
      number_with_precision(image.ave_value, precision: 2)
    else
      t('values.index.no_average')
    end
  end
end
