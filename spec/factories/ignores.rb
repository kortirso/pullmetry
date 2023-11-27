# frozen_string_literal: true

FactoryBot.define do
  factory :ignore do
    entity_value { 'entity[bot]' }
    insightable factory: %i[company]
  end
end
