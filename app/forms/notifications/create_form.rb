# frozen_string_literal: true

module Notifications
  class CreateForm
    include Deps[validator: 'validators.notification']

    def call(notifyable:, webhook:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      { result: notifyable.notifications.create!(params.merge(webhook: webhook)) }
    rescue ActiveRecord::RecordNotUnique => _e
      { errors: ['Notification already exists'] }
    end
  end
end
