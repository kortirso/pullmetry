# frozen_string_literal: true

FactoryBot.define do
  factory :subscriber do
    sequence(:email) { |i| "user#{i}@gmail.com" }
  end
end
