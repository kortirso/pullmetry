# frozen_string_literal: true

FactoryBot.define do
  factory :webhook do
    url { 'url' }
    company
  end
end
