# frozen_string_literal: true

module Notifications
  class CreateForm
    include Deps[validator: 'validators.notification']

    def call(notifyable:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      { result: notifyable.notifications.create!(params) }
    rescue ActiveRecord::RecordNotUnique => _e
      { errors: ['Notification already exists'] }
    end
  end
end
