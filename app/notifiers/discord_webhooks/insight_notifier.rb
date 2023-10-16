# frozen_string_literal: true

module DiscordWebhooks
  class InsightNotifier < DiscordWebhookNotifier
    def report
      notification(
        path: URI(insightable.configuration.insights_discord_webhook_url).path,
        body: {
          username: 'PullKeeper',
          content: DiscordWebhooks::Insight::ReportPayload.new.call(insightable: insightable)
        }
      )
    end

    private

    def insightable = params[:insightable]
  end
end
