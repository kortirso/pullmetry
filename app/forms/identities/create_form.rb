# frozen_string_literal: true

module Identities
  class CreateForm
    prepend ApplicationService
    include Validateable

    def call(user:, params:)
      return if validate_with(validator, params) && failure?

      ActiveRecord::Base.transaction do
        @result = user.identities.create!(params)
        attach_entities
      end
    end

    private

    def attach_entities
      # commento: entities.identity_id
      Entity
        .where(identity_id: nil, provider: @result.provider, login: @result.login)
        .update_all(identity_id: @result.id)
    end

    def validator = IdentityValidator
  end
end
