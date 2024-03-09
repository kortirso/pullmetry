# frozen_string_literal: true

module SlackWebhooks
  module Company
    class LongTimeReviewReportPayload
      include Deps[time_representer: 'services.converters.seconds_to_text']

      def call(insightable:)
        grouped_pull_requests = grouped_pull_requests(insightable)
        return no_long_time_block(insightable) if grouped_pull_requests.empty?

        {
          blocks: grouped_pull_requests.values.flat_map { |pull_requests|
            title(pull_requests.first[:repositories_title]) + metrics(pull_requests)
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
                text: "*Company #{insightable.title} doesn't have long time review*"
              }
            }
          ]
        }
      end

      def title(title)
        [
          {
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: "*Repository long time review of #{title}*"
            }
          }
        ]
      end

      def metrics(pull_requests)
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

      def grouped_pull_requests(insightable)
        insightable
          .pull_requests
          .opened
          .where('pull_requests.created_at < ?', (insightable.configuration.long_time_review_hours || 48).hours.ago)
          .joins(:repository)
          .order(created_at: :asc)
          .hashable_pluck(:created_at, :pull_number, :repository_id, 'repositories.title')
          .group_by { |element| element[:repository_id] }
      end
    end
  end
end
