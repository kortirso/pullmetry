# frozen_string_literal: true

FactoryBot.define do
  factory :entity do
    sequence(:external_id) { SecureRandom.uuid }
    login { 'octocat' }
  end
end
