# frozen_string_literal: true

class AccessTokenContract < ApplicationContract
  config.messages.namespace = :access_token

  params do
    required(:value).filled(:string)
  end
end
