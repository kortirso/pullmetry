# frozen_string_literal: true

FactoryBot.define do
  factory :issue do
    issue_number { 1 }
    opened_at { DateTime.now }
    repository
  end
end
