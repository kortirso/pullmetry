# frozen_string_literal: true

module Identities
  class CreateService
    prepend ApplicationService
    include Validateable

    def initialize(identity_validator: IdentityValidator)
      @identity_validator = identity_validator
    end

    def call(user:, params:)
      return if validate_with(@identity_validator, params) && failure?

      @result = user.identities.create!(params)
      attach_entities
    end

    private

    def attach_entities
      Entity
        .where(identity_id: nil, provider: @result.provider, login: @result.login)
        .update_all(identity_id: @result.id)
    end
  end
end
