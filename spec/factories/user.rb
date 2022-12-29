# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "user#{i}@gmail.com" }
    password { 'user123qwE' }
    confirmation_token { nil }
    confirmed_at { DateTime.now }

    trait :not_confirmed do
      confirmation_token { SecureRandom.hex }
      confirmed_at { nil }
    end
  end
end
