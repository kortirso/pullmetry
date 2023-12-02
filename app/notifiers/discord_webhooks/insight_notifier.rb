# frozen_string_literal: true

module DiscordWebhooks
  class InsightNotifier < DiscordWebhookNotifier
    def report
      notification(
        path: URI(insightable.webhooks.discord.first.url).path,
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
