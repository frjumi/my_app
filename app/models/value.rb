class Value < ApplicationRecord
  belongs_to :user
  belongs_to :image

  validates :value, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :image_id }

  after_save :recalculate_image_average
  after_destroy :recalculate_image_average

  private

  # Пересчёт средней оценки изображения после сохранения или удаления оценки
  def recalculate_image_average
    image.recalculate_ave_value!
  end
end
