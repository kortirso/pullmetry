# frozen_string_literal: true

module DiscordWebhooks
  class CompanyNotifier < DiscordWebhookNotifier
    include Companiable

    def insights_report
      notification(
        path: url(Webhook::DISCORD),
        body: {
          username: 'PullKeeper',
          content: DiscordWebhooks::Company::InsightsReportPayload.new.call(insightable: insightable)
        }
      )
    end

    def repository_insights_report
      notification(
        path: url(Webhook::DISCORD),
        body: {
          username: 'PullKeeper',
          content: repository_insights_report_payload.call(insightable: insightable)
        }
      )
    end

    private

    def repository_insights_report_payload
      Pullmetry::Container['notifiers.discord_webhooks.company.repository_insights_report_payload']
    end
  end
end
