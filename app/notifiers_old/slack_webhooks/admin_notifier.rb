# frozen_string_literal: true

module SlackWebhooks
  class AdminNotifier < SlackWebhookNotifier
    include Deps[
      job_execution_report_payload: 'notifiers.slack_webhooks.admin.job_execution_report_payload',
      feedback_created_payload: 'notifiers.slack_webhooks.admin.feedback_created_payload'
    ]

    def job_execution_report
      notification(
        path: URI(Rails.application.credentials[:reports_webhook_url]).path,
        body: job_execution_report_payload.call(job_name: params[:job_name])
      )
    end

    def feedback_created
      notification(
        path: URI(Rails.application.credentials[:reports_webhook_url]).path,
        body: feedback_created_payload.call(id: params[:id])
      )
    end
  end
end
