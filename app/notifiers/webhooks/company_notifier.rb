# frozen_string_literal: true

module Webhooks
  class CompanyNotifier < WebhookNotifier
    include Companiable

    def insights_report
      notification(
        url: url(Webhook::CUSTOM),
        body: { content: insights_report_payload.call(insightable: insightable) }
      )
    end

    def repository_insights_report
      notification(
        url: url(Webhook::CUSTOM),
        body: { content: repository_insights_report_payload.call(insightable: insightable) }
      )
    end

    def long_time_review_report
      notification(
        url: url(Webhook::CUSTOM),
        body: { content: long_time_review_report_payload.call(insightable: insightable) }
      )
    end

    private

    def insights_report_payload = Pullmetry::Container['notifiers.webhooks.company.insights_report_payload']

    def repository_insights_report_payload
      Pullmetry::Container['notifiers.webhooks.company.repository_insights_report_payload']
    end

    def long_time_review_report_payload
      Pullmetry::Container['notifiers.webhooks.company.long_time_review_report_payload']
    end
  end
end
