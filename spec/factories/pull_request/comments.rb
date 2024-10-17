# frozen_string_literal: true

FactoryBot.define do
  factory :pull_request_comment, class: 'PullRequest::Comment' do
    external_id { '1' }
    comment_created_at { DateTime.now }
    pull_request
    entity
  end
end
