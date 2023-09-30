# frozen_string_literal: true

module Identities
  class CreateForm
    include Deps[validator: 'validators.identity']

    def call(user:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      result = ActiveRecord::Base.transaction do
        identity = user.identities.create!(params)
        attach_entities(identity)
        identity
      end

      { result: result }
    end

    private

    def attach_entities(identity)
      # commento: entities.identity_id
      Entity
        .where(identity_id: nil, provider: identity.provider, login: identity.login)
        .update_all(identity_id: identity.id)
    end
  end
end
