# frozen_string_literal: true

class WebhookSerializer < ApplicationSerializer
  attributes :uuid, :source, :url
end
