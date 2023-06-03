# frozen_string_literal: true

module Export
  module Slack
    module Reports
      module Jobs
        class PayloadService
          prepend ApplicationService

          def call(job:)
            @job = job
            @result = { blocks: payload_block }
          end

          private

          def payload_block
            [
              {
                type: 'section',
                text: {
                  type: 'mrkdwn',
                  text: "#{@job.class.name} is run at #{DateTime.now}"
                }
              }
            ]
          end
        end
      end
    end
  end
end
