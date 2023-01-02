# frozen_string_literal: true

module Identities
  class CreateService
    prepend ApplicationService

    def initialize(identity_validator: IdentityValidator)
      @identity_validator = identity_validator
    end

    def call(user:, params:)
      return if validate_with(@identity_validator, params) && failure?

      @result = user.identities.create!(params)
    end
  end
end
