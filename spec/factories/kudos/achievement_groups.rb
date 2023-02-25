# frozen_string_literal: true

FactoryBot.define do
  factory :kudos_achievement_group, class: 'Kudos::AchievementGroup' do
    name { { en: 'General' } }
  end
end
