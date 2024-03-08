# frozen_string_literal: true

module Webhooks
  class CreateForm
    include Deps[validator: 'validators.webhook']

    def call(webhookable:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      error = validate_url(params)
      return { errors: [error] } if error.present?

      { result: webhookable.webhooks.create!(params) }
    rescue ActiveRecord::RecordNotUnique => _e
      { errors: ['Webhook already exists'] }
    end

    private

    # rubocop: disable Metrics/CyclomaticComplexity
    def validate_url(params)
      case params[:source]
      when Webhook::SLACK
        params[:url].start_with?('https://hooks.slack.com/services') ? nil : 'Invalid Slack webhook url'
      when Webhook::DISCORD
        params[:url].start_with?('https://discord.com/api/webhooks') ? nil : 'Invalid Discord webhook url'
      when Webhook::CUSTOM
        nil if URI(params[:url]).origin
      end
    # catches undefined method `origin' for #<URI::Generic> if url is invalid
    rescue NoMethodError => _e
      'Invalid Webhook url'
    end
    # rubocop: enable Metrics/CyclomaticComplexity
  end
end
