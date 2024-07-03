# frozen_string_literal: true

module SlackWebhooks
  module Company
    class RepositoryInsightsReportPayload
      include Deps[time_representer: 'services.converters.seconds_to_text']

      def call(insightable:)
        insights = insights(insightable)
        return no_repo_insights_block(insightable) if insights.empty?

        {
          blocks: insights.flat_map { |insight|
            (
              title(insight[:repositories_title]) +
              accessable_message(insight[:repositories_accessable]) +
              metrics(insight)
            ).compact
          }
        }
      end

      private

      def no_repo_insights_block(insightable)
        {
          blocks: [
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: "*Company #{insightable.title} doesn't have repository insights*"
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
              text: "*Repository insights of #{title}*"
            }
          }
        ]
      end

      def accessable_message(accessable)
        return [nil] if accessable

        [
          {
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: '*Repository has access error*'
            }
          }
        ]
      end

      def metrics(insight)
        [
          {
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: metric_data(insight)
            }
          }
        ]
      end

      # rubocop: disable Metrics/AbcSize
      def metric_data(insight)
        average_comment_time = time_representer.call(value: insight[:average_comment_time].to_i)
        average_review_time = time_representer.call(value: insight[:average_review_time].to_i)
        average_merge_time = time_representer.call(value: insight[:average_merge_time].to_i)

        [
          "*Average comment time:* #{average_comment_time}",
          "*Average review time:* #{average_review_time}",
          "*Average merge time:* #{average_merge_time}",
          "*Total comments:* #{insight[:comments_count].to_i}",
          "*Changed LOC:* #{insight[:changed_loc].to_i}",
          "*Open pull requests:* #{insight[:open_pull_requests_count].to_i}"
        ].join(', ')
      end
      # rubocop: enable Metrics/AbcSize

      def insights(insightable)
        ::Repositories::Insight
          .actual
          .joins(:repository)
          .where(repositories: { company_id: insightable.id })
          .hashable_pluck(
            :average_comment_time, :average_review_time, :average_merge_time,
            :comments_count, :changed_loc, :open_pull_requests_count,
            'repositories.title', 'repositories.accessable'
          )
      end
    end
  end
end
