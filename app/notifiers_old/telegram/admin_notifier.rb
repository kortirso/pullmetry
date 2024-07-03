# frozen_string_literal: true

module Telegram
  class AdminNotifier < TelegramNotifier
    include Deps[
      job_execution_report_payload: 'notifiers.telegram.admin.job_execution_report_payload',
      feedback_created_payload: 'notifiers.telegram.admin.feedback_created_payload'
    ]

    def job_execution_report
      notification(
        chat_id: Rails.application.credentials[:reports_telegram_chat_id],
        body: job_execution_report_payload.call(job_name: params[:job_name])
      )
    end

    def feedback_created
      notification(
        chat_id: Rails.application.credentials[:reports_telegram_chat_id],
        body: feedback_created_payload.call(id: params[:id])
      )
    end
  end
end
