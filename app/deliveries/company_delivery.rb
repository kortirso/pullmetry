# frozen_string_literal: true

class CompanyDelivery < ApplicationDelivery
  before_notify :ensure_webhook_enabled, on: :webhook
  before_notify :ensure_slack_enabled, on: :slack
  before_notify :ensure_discord_enabled, on: :discord
  before_notify :ensure_telegram_enabled, on: :telegram

  delivers :insights_report
  delivers :repository_insights_report
  delivers :long_time_review_report

  private

  def ensure_webhook_enabled
    sources.include?(Webhook::CUSTOM)
  end

  def ensure_slack_enabled
    sources.include?(Webhook::SLACK)
  end

  def ensure_discord_enabled
    sources.include?(Webhook::DISCORD)
  end

  def ensure_telegram_enabled
    sources.include?(Webhook::TELEGRAM)
  end

  def sources = params[:company].notifications.joins(:webhook).pluck('webhooks.source').uniq
end
