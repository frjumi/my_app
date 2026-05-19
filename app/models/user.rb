class User < ApplicationRecord
  has_many :values, dependent: :destroy

  before_save { self.email = email.downcase }
  before_create :create_remember_token

  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: VALID_EMAIL_REGEX }

  has_secure_password
  validates :password, length: { minimum: 6 }, allow_blank: true

  def self.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def self.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  # Оценки пользователя, расхождение с которыми от среднего не более 25%.
  def aligned_values(max_diff_ratio = 0.25)
    values
      .joins(:image)
      .where('images.ave_value IS NOT NULL AND images.ave_value > 0')
      .where('ABS(values.value - images.ave_value) <= images.ave_value * ?', max_diff_ratio)
      .includes(:image)
      .order('values.created_at DESC')
  end

  private

  def create_remember_token
    self.remember_token = User.encrypt(User.new_remember_token)
  end
end
