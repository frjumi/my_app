# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api rate_image', type: :request do
  let(:user) { create(:user) }
  let(:image) { create(:image) }

  before { sign_in(user) }

  describe 'POST /api/rate_image' do
    it 'создаёт новую оценку и пересчитывает среднее' do
      post '/api/rate_image', params: { image_id: image.id, value: 4 }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['status']).to eq('success')
      expect(body['new_total_values']).to eq(1)
      expect(body['user_value']).to eq(4)
      expect(image.reload.ave_value).to eq(4.0)
    end

    it 'обновляет существующую оценку' do
      create(:value, user: user, image: image, value: 2)
      image.recalculate_ave_value!

      post '/api/rate_image', params: { image_id: image.id, value: 5 }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['updated']).to be true
      expect(body['new_total_values']).to eq(1)
      expect(body['new_average']).to eq(5.0)
      expect(user.values.find_by(image: image).value).to eq(5)
    end

    it 'отклоняет некорректную оценку' do
      post '/api/rate_image', params: { image_id: image.id, value: 10 }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body['status']).to eq('error')
    end
  end
end
