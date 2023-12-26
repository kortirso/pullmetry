# frozen_string_literal: true

FactoryBot.define do
  factory :invite do
    inviteable factory: %i[company]
  end
end
