# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    title { 'Title' }
    name { 'company_name' }
    association :user
  end
end
