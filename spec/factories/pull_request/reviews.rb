# frozen_string_literal: true

FactoryBot.define do
  factory :pull_request_review, class: 'PullRequest::Review' do
    external_id { '1' }
    review_created_at { nil }
    pull_request
    entity
  end
end
