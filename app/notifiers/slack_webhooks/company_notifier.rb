# frozen_string_literal: true

module SlackWebhooks
  class CompanyNotifier < SlackWebhookNotifier
    include ::Companiable

    def insights_report
      notification(
        path: url(Webhook::SLACK),
        body: SlackWebhooks::Company::InsightsReportPayload.new.call(insightable: insightable)
      )
    end

    def repository_insights_report
      notification(
        path: url(Webhook::SLACK),
        body: repository_insights_report_payload.call(insightable: insightable)
      )
    end

    private

    def repository_insights_report_payload
      Pullmetry::Container['notifiers.slack_webhooks.company.repository_insights_report_payload']
    end
  end
end
