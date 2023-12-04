# frozen_string_literal: true

module Webhooks
  class InsightNotifier < WebhookNotifier
    def report
      notification(
        url: insightable.webhooks.custom.first.url,
        body: {
          content: Pullmetry::Container['notifiers.webhooks.insight.report_payload'].call(insightable: insightable)
        }
      )
    end

    private

    def insightable = params[:insightable]
  end
end
