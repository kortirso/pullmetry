# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    start_time { 1.day.ago }
    end_time { 1.day.after }
    association :user
  end
end
