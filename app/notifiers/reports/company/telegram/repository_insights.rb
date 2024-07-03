# frozen_string_literal: true

module Reports
  module Company
    module Telegram
      class RepositoryInsights < Reports::Company::RepositoryInsights
        include Deps[time_representer: 'services.converters.seconds_to_text']

        def call(insightable:)
          insights = insights(insightable)
          return no_error_label(insightable) if insights.empty?

          insights.map { |insight|
            [
              title(insight[:repositories_title]),
              accessable_message(insight[:repositories_accessable]),
              metrics(insight)
            ].join("\n")
          }.join("\n\n")
        end

        private

        # rubocop: disable Metrics/AbcSize
        def metrics(insight)
          average_comment_time = time_representer.call(value: insight[:average_comment_time].to_i)
          average_review_time = time_representer.call(value: insight[:average_review_time].to_i)
          average_merge_time = time_representer.call(value: insight[:average_merge_time].to_i)

          [
            "Average comment time: #{average_comment_time}",
            "Average review time: #{average_review_time}",
            "Average merge time: #{average_merge_time}",
            "Total comments: #{insight[:comments_count].to_i}",
            "Changed LOC: #{insight[:changed_loc].to_i}",
            "Open pull requests: #{insight[:open_pull_requests_count].to_i}"
          ].join(', ')
        end
        # rubocop: enable Metrics/AbcSize
      end
    end
  end
end
