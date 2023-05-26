# frozen_string_literal: true

FactoryBot.define do
  factory :pull_requests_comment, class: 'PullRequests::Comment' do
    external_id { '1' }
    comment_created_at { DateTime.now }
    pull_requests_entity
  end
end
