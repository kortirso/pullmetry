# frozen_string_literal: true

module SlackWebhooks
  module Admin
    class JobExecutionReportPayload
      def call(job:)
        { blocks: payload_block(job) }
      end

      private

      def payload_block(job)
        [
          {
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: "#{job.class.name} is run at #{DateTime.now}"
            }
          }
        ]
      end
    end
  end
end
