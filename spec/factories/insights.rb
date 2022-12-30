# frozen_string_literal: true

FactoryBot.define do
  factory :insight do
    comments_count { 0 }
    association :entity
    association :insightable, factory: :repository
  end
end
