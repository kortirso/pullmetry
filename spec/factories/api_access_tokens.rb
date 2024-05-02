# frozen_string_literal: true

FactoryBot.define do
  factory :api_access_token do
    value { SecureRandom.hex }
    user
  end
end
