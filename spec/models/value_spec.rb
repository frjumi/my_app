# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Value, type: :model do
  subject(:value) { build(:value) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:image) }

  it 'валидна с оценкой от 1 до 5' do
    value.value = 3
    expect(value).to be_valid
  end

  it 'не допускает оценку вне диапазона' do
    value.value = 6
    expect(value).not_to be_valid
  end

  it 'не допускает повторную оценку того же изображения' do
    existing = create(:value)
    duplicate = build(:value, user: existing.user, image: existing.image, value: 5)
    expect(duplicate).not_to be_valid
  end
end
