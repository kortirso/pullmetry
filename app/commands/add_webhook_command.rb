# frozen_string_literal: true

class AddWebhookCommand < BaseCommand
  use_contract do
    params do
      required(:company).filled(type?: Company)
      required(:source).filled(:string)
      required(:url).filled(:string)
    end

    rule(:source) do
      if Webhook.sources.keys.exclude?(values[:source])
        key(:source).failure(:unexisting)
      end
    end
  end

  private

  def do_validate(input)
    errors = super
    return errors if errors.present?

    error = validate_url(input)
    [error] if error
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
