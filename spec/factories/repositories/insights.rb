# frozen_string_literal: true

FactoryBot.define do
  factory :repositories_insight, class: 'Repositories::Insight' do
    comments_count { 0 }
    repository
  end
end
