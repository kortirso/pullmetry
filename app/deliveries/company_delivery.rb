# frozen_string_literal: true

class CompanyDelivery < ApplicationDelivery
  before_notify :ensure_mailer_enabled, on: :mailer
  before_notify :ensure_webhook_enabled, on: :webhook
  before_notify :ensure_slack_webhook_enabled, on: :slack_webhook
  before_notify :ensure_discord_webhook_enabled, on: :discord_webhook
  before_notify :ensure_telegram_enabled, on: :telegram

  delivers :insights_report
  delivers :repository_insights_report

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
    @webhook_sources ||=
      Webhook.where(webhookable: insightable)
        .or(Webhook.where(webhookable_type: 'Notification', webhookable_id: notifications.pluck(:id)))
        .pluck(:source)
        .uniq
  end

  def notifications
    @notifications ||=
      insightable.notifications.enabled.where(notification_type: notification_type).hashable_pluck(:id, :source)
  end

  def notification_sources
    @notification_sources ||= notifications.pluck(:source)
  end

  def notification_type
    case notification_name
    when :insights_report then Notification::INSIGHTS_DATA
    when :repository_insights_report then Notification::REPOSITORY_INSIGHTS_DATA
    end
  end

  def insightable = params[:insightable]
end
