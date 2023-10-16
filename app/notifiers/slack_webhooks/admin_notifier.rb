# frozen_string_literal: true

module SlackWebhooks
  class AdminNotifier < SlackWebhookNotifier
    include Deps[payload_service: 'notifiers.slack_webhooks.admin.job_execution_report_payload']

    def job_execution_report
      notification(
        path: URI(Rails.application.credentials[:reports_webhook_url]).path,
        body: payload_service.call(job_name: job_name)
      )
    end

    private

    def job_name = params[:job_name]
  end
end
