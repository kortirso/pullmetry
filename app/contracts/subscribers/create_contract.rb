# frozen_string_literal: true

module Subscribers
  class CreateContract < ApplicationContract
    config.messages.namespace = :subscriber

    params do
      required(:email).filled(:string)
    end

    rule(:email) do
      key.failure(:invalid) unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
    end
  end
end
