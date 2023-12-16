# frozen_string_literal: true

FactoryBot.define do
  factory :excludes_group, class: 'Excludes::Group' do
    insightable factory: %i[company]
  end
end
