# frozen_string_literal: true

module SlackWebhooks
  module Admin
    class JobExecutionReportPayload
      def call(job_name:)
        { blocks: payload_block(job_name) }
      end

      private

      def payload_block(job_name)
        [
          {
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: "#{job_name} is run at #{DateTime.now}"
            }
          }
        ]
      end
    end
  end
end
