# frozen_string_literal: true

FactoryBot.define do
  factory :user_vacation, class: 'User::Vacation' do
    start_time { 1.day.ago }
    end_time { 1.day.after }
    user
  end
end
