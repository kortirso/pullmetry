# frozen_string_literal: true

class NotificationContract < ApplicationContract
  config.messages.namespace = :notification

  params do
    required(:notification_type).filled(:string)
  end
end
