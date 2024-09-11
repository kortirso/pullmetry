# frozen_string_literal: true

class AddWebhookCommand < BaseCommand
  use_contract do
    config.messages.namespace = :webhook

    Sources = Dry::Types['strict.string'].enum(*Webhook.sources.keys)

    params do
      required(:company).filled(type?: Company)
      required(:source).filled(Sources)
      required(:url).filled(:string)
    end
  end

  private

  def validate_content(input)
    validate_url(input)
  end

  def do_persist(input)
    webhook = Webhook.create!(input)

    { result: webhook }
  rescue ActiveRecord::RecordNotUnique => _e
    { errors: ['Webhook already exists'] }
  end

  # rubocop: disable Metrics/CyclomaticComplexity
  def validate_url(input)
    case input[:source]
    when Webhook::SLACK
      input[:url].start_with?('https://hooks.slack.com/services') ? nil : 'Invalid Slack webhook url'
    when Webhook::DISCORD
      input[:url].start_with?('https://discord.com/api/webhooks') ? nil : 'Invalid Discord webhook url'
    when Webhook::CUSTOM
      nil if URI(input[:url]).origin
    end
  # catches undefined method `origin' for #<URI::Generic> if url is invalid
  rescue NoMethodError => _e
    'Invalid Webhook url'
  end
  # rubocop: enable Metrics/CyclomaticComplexity
end
