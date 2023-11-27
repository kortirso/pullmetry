# frozen_string_literal: true

class IgnoreContract < ApplicationContract
  config.messages.namespace = :ignore

  params do
    required(:entity_value).filled(:string)
  end
end
