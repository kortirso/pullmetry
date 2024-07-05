# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    notification_type { Notification::REPOSITORY_ACCESS_ERROR }
    notifyable factory: %i[company]
    webhook
  end
end
