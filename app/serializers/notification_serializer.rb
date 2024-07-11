# frozen_string_literal: true

class NotificationSerializer < ApplicationSerializer
  attributes :uuid, :notification_type, :webhooks_uuid

  def webhooks_uuid
    object.webhook.uuid
  end
end
