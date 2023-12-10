# frozen_string_literal: true

class NotificationContract < ApplicationContract
  config.messages.namespace = :notification

  params do
    required(:source).filled(:string)
    required(:notification_type).filled(:string)
  end

  rule(:source) do
    if Notification.sources.keys.exclude?(values[:source])
      key(:source).failure(:unexisting)
    end
  end
end
