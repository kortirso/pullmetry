# frozen_string_literal: true

class AdminDelivery < ApplicationDelivery
  before_notify :ensure_webhook_enabled, on: :webhook
  before_notify :ensure_slack_enabled, on: :slack
  before_notify :ensure_discord_enabled, on: :discord
  before_notify :ensure_telegram_enabled, on: :telegram

  delivers :job_execution_report
  delivers :feedback_created

  private

  def ensure_webhook_enabled = false
  def ensure_slack_enabled = false
  def ensure_discord_enabled = false
  def ensure_telegram_enabled = true
end
