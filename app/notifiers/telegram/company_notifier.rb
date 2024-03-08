# frozen_string_literal: true

module Telegram
  class CompanyNotifier < TelegramNotifier
    include Companiable

    def insights_report
      notification(
        chat_id: url(Webhook::TELEGRAM),
        body: insights_report_payload.call(insightable: insightable)
      )
    end

    def repository_insights_report
      notification(
        chat_id: url(Webhook::TELEGRAM),
        body: repository_insights_report_payload.call(insightable: insightable)
      )
    end

    def long_time_review_report
      notification(
        chat_id: url(Webhook::TELEGRAM),
        body: long_time_review_report_payload.call(insightable: insightable)
      )
    end

    private

    def insights_report_payload = Pullmetry::Container['notifiers.telegram.company.insights_report_payload']

    def repository_insights_report_payload
      Pullmetry::Container['notifiers.telegram.company.repository_insights_report_payload']
    end

    def long_time_review_report_payload
      Pullmetry::Container['notifiers.telegram.company.long_time_review_report_payload']
    end
  end
end
