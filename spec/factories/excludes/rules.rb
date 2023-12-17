# frozen_string_literal: true

FactoryBot.define do
  factory :excludes_rule, class: 'Excludes::Rule' do
    target { Excludes::Rule::DESTINATION_BRANCH_NAME_TARGET }
    condition { Excludes::Rule::EQUAL_CONDITION }
    value { 'master' }
    excludes_group
  end
end
