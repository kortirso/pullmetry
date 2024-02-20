# frozen_string_literal: true

module Subscribers
  class CreateForm
    include Deps[validator: 'validators.subscribers.create']

    def call(params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      result = Subscriber.create!(params)
      SubscribersMailer.create_email(id: result.id).deliver_later

      { result: result }
    end
  end
end
