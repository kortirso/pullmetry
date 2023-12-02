# frozen_string_literal: true

module Webhooks
  class CreateForm
    include Deps[validator: 'validators.webhook']

    def call(company:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      error = validate_single_source(company, params)
      return { errors: [error] } if error.present?

      error = validate_url(params)
      return { errors: [error] } if error.present?

      { result: company.webhooks.create!(params) }
    rescue ActiveRecord::RecordNotUnique => _e
      { errors: ['Webhook already exists'] }
    end

    private

    def validate_single_source(company, params)
      return unless company.webhooks.exists?(source: params[:source])

      'There is already webhook with such source'
    end

    def validate_url(params)
      case params[:source]
      when Webhook::SLACK
        params[:url].start_with?('https://hooks.slack.com/services') ? nil : 'Invalid Slack webhook url'
      when Webhook::DISCORD
        params[:url].start_with?('https://discord.com/api/webhooks') ? nil : 'Invalid Discord webhook url'
      end
    end
  end
end
