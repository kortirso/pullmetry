# frozen_string_literal: true

FactoryBot.define do
  factory :feedback, class: 'User::Feedback' do
    title { 'Title' }
    description { 'Text' }
    user
  end
end
