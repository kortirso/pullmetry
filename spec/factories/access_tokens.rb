# frozen_string_literal: true

FactoryBot.define do
  factory :access_token do
    value { SecureRandom.hex }
    association :tokenable, factory: :repository
  end
end
