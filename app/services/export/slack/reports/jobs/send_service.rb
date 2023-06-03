# frozen_string_literal: true

module Export
  module Slack
    module Reports
      module Jobs
        class SendService
          prepend ApplicationService

          def initialize(
            payload_service: PayloadService.new,
            send_service: SlackHooksApi::Client.new
          )
            @payload_service = payload_service
            @send_service = send_service
          end

          def call(job:)
            @send_service.send_message(
              path: URI(webhook_url).path,
              body: @payload_service.call(job: job).result
            )
          end

          private

          def webhook_url
            Rails.application.credentials[:reports_webhook_url]
          end
        end
      end
    end
  end
end
