# frozen_string_literal: true

module Telegram
  class InsightNotifier < TelegramNotifier
    def report
      notification(
        chat_id: insightable.webhooks.telegram.first.url,
        body: Pullmetry::Container['notifiers.telegram.insight.report_payload'].call(insightable: insightable)
      )
    end

    private

    def insightable = params[:insightable]
  end
end
