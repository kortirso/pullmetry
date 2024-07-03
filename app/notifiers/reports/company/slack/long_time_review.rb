# frozen_string_literal: true

module Reports
  module Company
    module Slack
      class LongTimeReview < Reports::Company::LongTimeReview
        include Deps[time_representer: 'services.converters.seconds_to_text']

        def call(insightable:)
          grouped_pull_requests = grouped_pull_requests(insightable)
          return no_long_time_block(insightable) if grouped_pull_requests.empty?

          {
            blocks: grouped_pull_requests.values.flat_map { |pull_requests|
              title_block(pull_requests.first[:repositories_title]) + metrics_block(pull_requests)
            }
          }
        end

        private

        def no_long_time_block(insightable)
          {
            blocks: [
              {
                type: 'section',
                text: {
                  type: 'mrkdwn',
                  text: "*#{no_error_label(insightable)}*"
                }
              }
            ]
          }
        end

        def title_block(title)
          [
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: "*#{title(title)}*"
              }
            }
          ]
        end

        def metrics_block(pull_requests)
          pull_requests.map { |pull_request|
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: metric_data(pull_request)
              }
            }
          }
        end

        def metric_data(pull_request)
          in_progress_time = time_representer.call(value: DateTime.now.to_i - pull_request[:created_at].to_i)

          [
            "*Pull number:* #{pull_request[:pull_number]}",
            "*In review time:* #{in_progress_time}"
          ].join(', ')
        end
      end
    end
  end
end
