# frozen_string_literal: true

FactoryBot.define do
  factory :companies_user, class: 'Companies::User' do
    company
    user
    invite
  end
end
