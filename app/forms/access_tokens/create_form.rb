# frozen_string_literal: true

module AccessTokens
  class CreateForm
    include Deps[validator: 'validators.access_token']

    def call(tokenable:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      ActiveRecord::Base.transaction do
        tokenable.access_token&.destroy
        tokenable.create_access_token!(params)
      end
    end
  end
end
