# frozen_string_literal: true

class UserContract < ApplicationContract
  config.messages.namespace = :user

  params do
    required(:email).filled(:string)
  end

  rule(:email) do
    unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
      key.failure(:invalid)
    end
  end
end
