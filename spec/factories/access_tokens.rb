# frozen_string_literal: true

FactoryBot.define do
  factory :access_token do
    value { SecureRandom.hex }
    tokenable factory: %i[repository]
  end
end
