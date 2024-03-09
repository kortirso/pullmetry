# frozen_string_literal: true

class NotificationSerializer < ApplicationSerializer
  attributes :uuid, :source, :notification_type
end
