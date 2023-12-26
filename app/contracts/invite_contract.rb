# frozen_string_literal: true

class InviteContract < ApplicationContract
  config.messages.namespace = :invite

  params do
    required(:email).filled(:string)
  end
end
