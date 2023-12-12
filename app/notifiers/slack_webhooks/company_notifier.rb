# frozen_string_literal: true

module SlackWebhooks
  class CompanyNotifier < SlackWebhookNotifier
    def insights_report
      notification(
        path: URI(insightable.webhooks.slack.first.url).path,
        body: SlackWebhooks::Company::InsightsReportPayload.new.call(insightable: insightable)
      )
    end

    def repository_insights_report
      notification(
        path: URI(insightable.webhooks.slack.first.url).path,
        body: repository_insights_report_payload.call(insightable: insightable)
      )
    end

    private

    def insightable = params[:insightable]

    def repository_insights_report_payload
      Pullmetry::Container['notifiers.slack_webhooks.company.repository_insights_report_payload']
    end
  end
end
