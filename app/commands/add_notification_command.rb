# frozen_string_literal: true

class AddNotificationCommand < BaseCommand
  use_contract do
    NotificationTypes = Dry::Types['strict.string'].enum(*Notification.notification_types.keys)

    params do
      required(:notifyable).filled(type?: ApplicationRecord)
      required(:webhook).filled(type?: Webhook)
      required(:notification_type).filled(NotificationTypes)
    end
  end

  private

  def validate_content(input)
    validate_notifyable_type(input)
  end

  def do_persist(input)
    notification = Notification.create!(input)

    { result: notification }
  rescue ActiveRecord::RecordNotUnique => _e
    { errors: ['Notification already exists'] }
  end

  def validate_notifyable_type(input)
    return if input[:notifyable].class.name.in?(Notification::NOTIFYABLE_TYPES)

    'Notifyable is not supported'
  end
end
