# frozen_string_literal: true

FactoryBot.define do
  factory :user_session, class: 'User::Session' do
    user
  end
end
