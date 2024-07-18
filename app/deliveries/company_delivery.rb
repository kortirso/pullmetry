# frozen_string_literal: true

class CompanyDelivery < ApplicationDelivery
  before_notify :ensure_webhook_enabled, on: :webhook
  before_notify :ensure_slack_enabled, on: :slack
  before_notify :ensure_discord_enabled, on: :discord
  before_notify :ensure_telegram_enabled, on: :telegram

  delivers :insights_report
  delivers :repository_insights_report
  delivers :long_time_review_report
  delivers :no_new_pulls_report

  private

  def ensure_webhook_enabled
    webhook.custom?
  end

  def ensure_slack_enabled
    webhook.slack?
  end

  def ensure_discord_enabled
    webhook.discord?
  end

  def ensure_telegram_enabled
    webhook.telegram?
  end

  def webhook = params[:notification].webhook
end
