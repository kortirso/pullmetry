# frozen_string_literal: true

class WebhookSerializer < ApplicationSerializer
  attributes :id, :source, :url
end
