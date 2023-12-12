# frozen_string_literal: true

module Telegram
  class CompanyNotifier < TelegramNotifier
    def insights_report
      notification(
        chat_id: insightable.webhooks.telegram.first.url,
        body: insights_report_payload.call(insightable: insightable)
      )
    end

    def repository_insights_report
      notification(
        chat_id: insightable.webhooks.telegram.first.url,
        body: repository_insights_report_payload.call(insightable: insightable)
      )
    end

    private

    def insightable = params[:insightable]
    def insights_report_payload = Pullmetry::Container['notifiers.telegram.company.insights_report_payload']

    def repository_insights_report_payload
      Pullmetry::Container['notifiers.telegram.company.repository_insights_report_payload']
    end
  end
end
