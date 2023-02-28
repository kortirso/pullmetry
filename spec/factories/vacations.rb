# frozen_string_literal: true

FactoryBot.define do
  factory :vacation do
    association :user
  end
end
