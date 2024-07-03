# frozen_string_literal: true

class CompanyWebhookNotifier < CompanyNotifier
  self.driver = proc do |data|
    url = URI(data[:path])

    Webhooks::Client.new(url: url.origin).send_message(
      path: url.path,
      body: data[:body]
    )
  end

  def insights_report = report(Webhook::CUSTOM)
  def repository_insights_report = report(Webhook::CUSTOM)
  def long_time_review_report = report(Webhook::CUSTOM)
end
