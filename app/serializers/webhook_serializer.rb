# frozen_string_literal: true

class WebhookSerializer < ApplicationSerializer
  attributes :uuid, :source, :url, :webhookable_type

  attribute :webhookable_uuid do |object|
    object.webhookable_type == 'Company' ? nil : object.webhookable.uuid
  end
end
