# frozen_string_literal: true

FactoryBot.define do
  factory :repository do
    title { 'Title' }
    link { 'https://github.com/company_name/repo_name' }
    association :company
  end
end
