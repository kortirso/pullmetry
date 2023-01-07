# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    title { 'Title' }
    association :user
  end
end
