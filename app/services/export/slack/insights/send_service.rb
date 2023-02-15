# frozen_string_literal: true

module Export
  module Slack
    module Insights
      class SendService
        prepend ApplicationService

        def initialize(
          payload_service: PayloadService.new,
          send_service: SlackHooksApi::Client.new
        )
          @payload_service = payload_service
          @send_service = send_service
        end

        def call(insightable:)
          return unless insightable.premium?
          return if insightable.configuration.insights_webhook_url.blank?

          @send_service.send_message(
            path: URI(insightable.configuration.insights_webhook_url).path,
            body: @payload_service.call(insightable: insightable).result
          )
        end
      end
    end
  end
end
