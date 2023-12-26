# frozen_string_literal: true

module Invites
  class CreateForm
    include Deps[validator: 'validators.invite']

    def call(inviteable:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      { result: inviteable.invites.create!(params) }
    end
  end
end
