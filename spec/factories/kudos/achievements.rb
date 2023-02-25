# frozen_string_literal: true

FactoryBot.define do
  factory :kudos_achievement, class: 'Kudos::Achievement' do
    award_name { 'comment_create' }
    points { 5 }
    association :kudos_achievement_group
  end
end
