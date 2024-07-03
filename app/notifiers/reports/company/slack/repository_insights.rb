# frozen_string_literal: true

module Reports
  module Company
    module Slack
      class RepositoryInsights < Reports::Company::RepositoryInsights
        include Deps[time_representer: 'services.converters.seconds_to_text']

        def call(insightable:)
          insights = insights(insightable)
          return no_repo_insights_block(insightable) if insights.empty?

          {
            blocks: insights.flat_map { |insight|
              (
                title_block(insight[:repositories_title]) +
                accessable_message_block(insight[:repositories_accessable]) +
                metrics_block(insight)
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

        def accessable_message_block(accessable)
          message = accessable_message(accessable)
          return [nil] if message.blank?

          [
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: "*#{message}*"
              }
            }
          ]
        end

        def metrics_block(insight)
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
      end
    end
  end
end
