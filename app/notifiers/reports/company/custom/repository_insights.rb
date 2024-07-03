# frozen_string_literal: true

module Reports
  module Company
    module Custom
      class RepositoryInsights < Reports::Company::RepositoryInsights
        def call(insightable:)
          insights = insights(insightable)
          return no_error_label(insightable) if insights.empty?

          insights.map do |insight|
            {
              title: title(insight[:repositories_title]),
              accessable: accessable_message(insight[:repositories_accessable]),
              metrics: metrics(insight)
            }
          end
        end

        private

        def metrics(insight)
          {
            average_comment_seconds: insight[:average_comment_time].to_i,
            average_review_seconds: insight[:average_review_time].to_i,
            average_merge_seconds: insight[:average_merge_time].to_i,
            comments_count: insight[:comments_count].to_i,
            changed_loc: insight[:changed_loc].to_i,
            open_pull_requests_count: insight[:open_pull_requests_count].to_i
          }
        end
      end
    end
  end
end
