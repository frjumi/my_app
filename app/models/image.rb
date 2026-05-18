class Image < ApplicationRecord
  belongs_to :theme
  has_many :values, dependent: :destroy
end