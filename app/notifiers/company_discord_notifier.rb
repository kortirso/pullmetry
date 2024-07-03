# frozen_string_literal: true

class CompanyDiscordNotifier < CompanyNotifier
  self.driver = proc do |data|
    Pullmetry::Container['api.discord.client'].send_message(
      path: data[:path],
      body: data[:body]
    )
  end

  def insights_report = report(Webhook::DISCORD)
  def repository_insights_report = report(Webhook::DISCORD)
  def long_time_review_report = report(Webhook::DISCORD)
end
