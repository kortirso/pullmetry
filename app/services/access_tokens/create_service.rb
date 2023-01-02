# frozen_string_literal: true

module AccessTokens
  class CreateService
    prepend ApplicationService

    def initialize(access_token_validator: AccessTokenValidator)
      @access_token_validator = access_token_validator
    end

    def call(tokenable:, params:)
      return if validate_with(@access_token_validator, params) && failure?

      @result = tokenable.create_access_token!(params)
    end
  end
end
