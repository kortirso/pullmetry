# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "user#{i}@gmail.com" }
    role { User::REGULAR }

    trait :admin do
      role { User::ADMIN }
    end
  end
end
