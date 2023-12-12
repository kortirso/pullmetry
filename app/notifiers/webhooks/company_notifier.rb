# frozen_string_literal: true

module Webhooks
  class CompanyNotifier < WebhookNotifier
    def insights_report
      notification(
        url: insightable.webhooks.custom.first.url,
        body: { content: insights_report_payload.call(insightable: insightable) }
      )
    end

    def repository_insights_report
      notification(
        url: insightable.webhooks.custom.first.url,
        body: { content: repository_insights_report_payload.call(insightable: insightable) }
      )
    end

    private

    def insightable = params[:insightable]
    def insights_report_payload = Pullmetry::Container['notifiers.webhooks.company.insights_report_payload']

    def repository_insights_report_payload
      Pullmetry::Container['notifiers.webhooks.company.repository_insights_report_payload']
    end
  end
end
