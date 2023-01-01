# frozen_string_literal: true

FactoryBot.define do
  factory :pull_requests_review, class: 'PullRequests::Review' do
    external_id { '1' }
    review_created_at { DateTime.now }
    association :pull_requests_entity
  end
end
