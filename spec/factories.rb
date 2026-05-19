# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
  end

  factory :theme do
    sequence(:name) { |n| "theme#{n}" }
    qty_items { 1 }
  end

  factory :image do
    sequence(:name) { |n| "image#{n}" }
    file { 'test_image.jpg' }
    theme
  end

  factory :value do
    user
    image
    value { 4 }
  end
end
