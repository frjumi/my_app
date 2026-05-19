class Image < ApplicationRecord
  belongs_to :theme
  has_many :values, dependent: :destroy

  scope :theme_images, ->(theme_id) { select(:id, :name, :file, :ave_value).where(theme_id: theme_id) }

  # Пересчитывает среднюю оценку по всем оценкам изображения.
  def recalculate_ave_value!
    avg = values.average(:value)
    update!(ave_value: avg ? avg.round(2) : nil)
  end
end
