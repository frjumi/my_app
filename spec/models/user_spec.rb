# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it { is_expected.to have_many(:values).dependent(:destroy) }

  it 'валиден с корректными атрибутами' do
    expect(user).to be_valid
  end

  it 'требует уникальный email' do
    create(:user, email: 'dup@example.com')
    user.email = 'dup@example.com'
    expect(user).not_to be_valid
  end

  describe '#aligned_values' do
    let(:user) { create(:user) }
    let(:theme) { create(:theme) }
    let(:image) { create(:image, theme: theme, ave_value: 4.0) }

    it 'возвращает оценки в пределах 25% от среднего' do
      create(:value, user: user, image: image, value: 4)
      expect(user.aligned_values.map(&:image_id)).to include(image.id)
    end

    it 'не включает оценки с большим расхождением' do
      create(:value, user: user, image: image, value: 1)
      expect(user.aligned_values).to be_empty
    end
  end
end
