# frozen_string_literal: true

class WebhookContract < ApplicationContract
  config.messages.namespace = :webhook

  params do
    required(:source).filled(:string)
    required(:url).filled(:string)
  end

  rule(:source) do
    if Webhook.sources.keys.exclude?(values[:source])
      key(:source).failure(:unexisting)
    end
  end
end
