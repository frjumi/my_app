class Theme < ApplicationRecord
  has_many :images, dependent: :nullify
end