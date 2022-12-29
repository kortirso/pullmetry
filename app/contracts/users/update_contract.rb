# frozen_string_literal: true

module Users
  class UpdateContract < ApplicationContract
    config.messages.namespace = :user

    params do
      required(:password).filled(:string)
      required(:password_confirmation).filled(:string)
    end

    rule(:password, :password_confirmation) do
      key(:passwords).failure(:different) if values[:password] != values[:password_confirmation]
    end

    rule(:password) do
      if values[:password].size < Rails.configuration.minimum_password_length
        key.failure(
          I18n.t(
            'dry_validation.errors.user.password_length',
            length: Rails.configuration.minimum_password_length
          )
        )
      end
    end
  end
end
