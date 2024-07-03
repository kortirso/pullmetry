# frozen_string_literal: true

class CompanyDiscordNotifier < CompanyNotifier
  self.driver = proc do |data|
    Pullmetry::Container['api.slack.client'].send_message(
      path: data[:path],
      body: data[:body]
    )
  end

  def insights_report = report(Webhook::SLACK)
  def repository_insights_report = report(Webhook::SLACK)
  def long_time_review_report = report(Webhook::SLACK)
end
