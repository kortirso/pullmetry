# frozen_string_literal: true

module Users
  class UpdateContract < ApplicationContract
    config.messages.namespace = :user

    params do
      required(:password).filled(:string)
      required(:password_confirmation).filled(:string)
    end
  end
end
