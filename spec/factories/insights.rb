# frozen_string_literal: true

FactoryBot.define do
  factory :insight do
    comments_count { 0 }
    entity
    insightable factory: %i[repository]
  end
end
