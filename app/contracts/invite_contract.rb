# frozen_string_literal: true

class InviteContract < ApplicationContract
  config.messages.namespace = :invite

  params do
    required(:email).filled(:string)
  end

  rule(:email) do
    key.failure(:invalid) unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
  end
end
