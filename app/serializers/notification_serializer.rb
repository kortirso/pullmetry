# frozen_string_literal: true

class NotificationSerializer < ApplicationSerializer
  attributes :uuid, :notification_type

  attribute :webhooks_uuid do |object|
    object.webhook.uuid
  end
end
