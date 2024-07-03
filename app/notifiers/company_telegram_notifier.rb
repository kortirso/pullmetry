# frozen_string_literal: true

class CompanyTelegramNotifier < CompanyNotifier
  self.driver = proc do |data|
    Pullmetry::Container['api.telegram.client'].send_message(
      bot_secret: Rails.application.credentials.dig(:telegram_oauth, Rails.env.to_sym, :bot_secret),
      chat_id: data[:chat_id],
      text: data[:body]
    )
  end

  def insights_report = report(Webhook::TELEGRAM)
  def repository_insights_report = report(Webhook::TELEGRAM)
  def long_time_review_report = report(Webhook::TELEGRAM)
end
