# frozen_string_literal: true

class InsightDelivery < ApplicationDelivery
  before_notify :ensure_mailer_enabled, on: :mailer
  before_notify :ensure_webhook_enabled, on: :webhook
  before_notify :ensure_slack_webhook_enabled, on: :slack_webhook
  before_notify :ensure_discord_webhook_enabled, on: :discord_webhook
  before_notify :ensure_telegram_enabled, on: :telegram

  delivers :report

  private

  def ensure_mailer_enabled = false

  def ensure_webhook_enabled
    return false if webhook_sources.exclude?(Webhook::CUSTOM)
    return false if notification_sources.exclude?(Notification::CUSTOM)

    true
  end

  def ensure_slack_webhook_enabled
    return false if webhook_sources.exclude?(Webhook::SLACK)
    return false if notification_sources.exclude?(Notification::SLACK)

    true
  end

  def ensure_discord_webhook_enabled
    return false if webhook_sources.exclude?(Webhook::DISCORD)
    return false if notification_sources.exclude?(Notification::DISCORD)

    true
  end

  def ensure_telegram_enabled
    return false if webhook_sources.exclude?(Webhook::TELEGRAM)
    return false if notification_sources.exclude?(Notification::TELEGRAM)

    true
  end

  def webhook_sources
    @webhook_sources ||= insightable.webhooks.pluck(:source)
  end

  def notification_sources
    @notification_sources ||=
      insightable.notifications.where(notification_type: Notification::INSIGHTS_DATA).pluck(:source)
  end

  def insightable = params[:insightable]
end
