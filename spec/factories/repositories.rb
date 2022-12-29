# frozen_string_literal: true

FactoryBot.define do
  factory :repository do
    title { 'Title' }
    name { 'repo_name' }
    association :company
  end
end
