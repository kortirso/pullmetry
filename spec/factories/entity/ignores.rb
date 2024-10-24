# frozen_string_literal: true

FactoryBot.define do
  factory :ignore, class: 'Entity::Ignore' do
    entity_value { 'entity[bot]' }
    insightable factory: %i[company]
  end
end
