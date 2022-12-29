# frozen_string_literal: true

FactoryBot.define do
  factory :pull_request do
    association :repository
  end
end
