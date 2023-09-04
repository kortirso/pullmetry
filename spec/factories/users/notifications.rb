# frozen_string_literal: true

FactoryBot.define do
  factory :users_notification, class: 'Users::Notification' do
    notification_type { Users::Notification::ACCESS_ERROR }
    value { false }
    user
  end
end
