# frozen_string_literal: true

FactoryBot.define do
  factory :issue_comment, class: 'Issue::Comment' do
    external_id { '1' }
    comment_created_at { DateTime.now }
    issue
  end
end
