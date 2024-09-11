# frozen_string_literal: true

FactoryBot.define do
  factory :work_time do
    starts_at { '09:00' }
    ends_at { '18:00' }
    timezone { '0' }
    worktimeable factory: %i[user]
  end
end
