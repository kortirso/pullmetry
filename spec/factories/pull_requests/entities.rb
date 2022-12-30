# frozen_string_literal: true

FactoryBot.define do
  factory :pull_requests_entity, class: 'PullRequests::Entity' do
    association :pull_request
    association :entity
  end
end
