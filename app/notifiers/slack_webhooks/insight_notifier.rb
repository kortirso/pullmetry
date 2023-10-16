# frozen_string_literal: true

module SlackWebhooks
  class InsightNotifier < SlackWebhookNotifier
    def report
      notification(
        path: URI(insightable.configuration.insights_webhook_url).path,
        body: SlackWebhooks::Insight::ReportPayload.new.call(insightable: insightable)
      )
    end

    private

    def insightable = params[:insightable]
  end
end
