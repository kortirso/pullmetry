# frozen_string_literal: true

class AdminDelivery < ApplicationDelivery
  before_notify :ensure_mailer_enabled, on: :mailer
  before_notify :ensure_webhook_enabled, on: :webhook
  before_notify :ensure_slack_webhook_enabled, on: :slack_webhook
  before_notify :ensure_discord_webhook_enabled, on: :discord_webhook
  before_notify :ensure_telegram_enabled, on: :telegram

  delivers :job_execution_report
  delivers :feedback_created

  private

  def ensure_mailer_enabled = false
  def ensure_webhook_enabled = false
  def ensure_slack_webhook_enabled = false
  def ensure_discord_webhook_enabled = false
  def ensure_telegram_enabled = true
end
