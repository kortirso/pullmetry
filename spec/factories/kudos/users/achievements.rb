# frozen_string_literal: true

FactoryBot.define do
  factory :kudos_users_achievement, class: 'Kudos::Users::Achievement' do
    user
    kudos_achievement
  end
end
