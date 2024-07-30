# frozen_string_literal: true

class AddNotificationCommand < BaseCommand
  use_contract do
    params do
      required(:notifyable).filled(type?: ApplicationRecord)
      required(:webhook).filled(type?: Webhook)
      required(:notification_type).filled(:string)
    end
  end

  private

  def do_validate(input)
    errors = super
    return errors if errors.present?

    error = validate_notifyable_type(input)
    [error] if error
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
