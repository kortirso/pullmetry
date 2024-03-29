# frozen_string_literal: true

FactoryBot.define do
  factory :pull_request do
    pull_number { 1 }
    pull_created_at { DateTime.now }
    repository
    entity
  end
end
