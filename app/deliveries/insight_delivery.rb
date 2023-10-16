# frozen_string_literal: true

class InsightDelivery < ApplicationDelivery
  before_notify :ensure_mailer_enabled, on: :mailer
  before_notify :ensure_slack_webhook_enabled, on: :slack_webhook
  before_notify :ensure_discord_webhook_enabled, on: :discord_webhook

  delivers :report

  private

  def ensure_mailer_enabled = false

  def ensure_slack_webhook_enabled
    return false unless insightable.premium?
    return false if insightable.configuration.insights_webhook_url.blank?

    true
  end

  def ensure_discord_webhook_enabled
    return false unless insightable.premium?
    return false if insightable.configuration.insights_discord_webhook_url.blank?

    true
  end

  def insightable = params[:insightable]
end
