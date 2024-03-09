# frozen_string_literal: true

module Feedbacks
  class CreateForm
    include Deps[validator: 'validators.feedback']

    def call(user:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      feedback = user.feedbacks.create!(params)
      AdminDelivery.with(id: feedback.id).feedback_created.deliver_later

      { result: feedback }
    end
  end
end
