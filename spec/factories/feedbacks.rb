# frozen_string_literal: true

FactoryBot.define do
  factory :feedback do
    title { 'Title' }
    description { 'Text' }
    user
  end
end
