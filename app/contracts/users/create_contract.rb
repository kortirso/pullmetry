# frozen_string_literal: true

module Users
  class CreateContract < ApplicationContract
    config.messages.namespace = :user

    params do
      required(:email).filled(:string)
      required(:password).filled(:string)
      required(:password_confirmation).filled(:string)
    end

    rule(:email) do
      unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
        key.failure(:invalid)
      end
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
