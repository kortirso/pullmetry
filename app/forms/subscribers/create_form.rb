# frozen_string_literal: true

module Subscribers
  class CreateForm
    include Deps[validator: 'validators.subscribers.create']

    def call(params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      result = Subscriber.create!(params)
      # TODO: add sending welcome email

      { result: result }
    end
  end
end
