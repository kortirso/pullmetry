# frozen_string_literal: true

FactoryBot.define do
  factory :users_session, class: 'Users::Session' do
    association :user
  end
end
