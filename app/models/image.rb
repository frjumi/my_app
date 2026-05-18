class Image < ApplicationRecord
  belongs_to :theme
  has_many :values, dependent: :destroy
  # app/models/image.rb
  scope :theme_images, ->(theme_id) { select(:id, :name, :file, :ave_value).where(theme_id: theme_id) }
end