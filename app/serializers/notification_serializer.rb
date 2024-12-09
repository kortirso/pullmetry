# frozen_string_literal: true

class NotificationSerializer < ApplicationSerializer
  attributes :id, :notification_type, :webhook_id
end
