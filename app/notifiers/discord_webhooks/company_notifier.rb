# frozen_string_literal: true

module DiscordWebhooks
  class CompanyNotifier < DiscordWebhookNotifier
    def insights_report
      notification(
        path: URI(insightable.webhooks.discord.first.url).path,
        body: {
          username: 'PullKeeper',
          content: DiscordWebhooks::Company::InsightsReportPayload.new.call(insightable: insightable)
        }
      )
    end

    def repository_insights_report
      notification(
        path: URI(insightable.webhooks.discord.first.url).path,
        body: {
          username: 'PullKeeper',
          content: repository_insights_report_payload.call(insightable: insightable)
        }
      )
    end

    private

    def insightable = params[:insightable]

    def repository_insights_report_payload
      Pullmetry::Container['notifiers.discord_webhooks.company.repository_insights_report_payload']
    end
  end
end
