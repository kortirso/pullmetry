# frozen_string_literal: true

FactoryBot.define do
  factory :identity do
    uid { '12345' }
    provider { 'github' }
    email { 'email@gmail.com' }
    login { 'login' }
    association :user
  end
end
