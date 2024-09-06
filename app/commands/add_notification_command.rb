# frozen_string_literal: true

class AddNotificationCommand < BaseCommand
  use_contract do
    NotificationTypes = Dry::Types['strict.string'].enum(*Notification.notification_types.keys)

    params do
      required(:notifyable).filled(type_included_in?: [Company, Repository])
      required(:webhook).filled(type?: Webhook)
      required(:notification_type).filled(NotificationTypes)
    end
  end

  private

  def do_persist(input)
    notification = Notification.create!(input)

    { result: notification }
  rescue ActiveRecord::RecordNotUnique => _e
    { errors: ['Notification already exists'] }
  end
end
