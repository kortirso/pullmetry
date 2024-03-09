# frozen_string_literal: true

module Webhooks
  module Company
    class RepositoryInsightsReportPayload
      def call(insightable:)
        insights = insights(insightable)
        return "Company #{insightable.title} doesn't have repository insights" if insights.empty?

        insights.map do |insight|
          {
            title: title(insight[:repositories_title]),
            accessable: accessable_message(insight[:repositories_accessable]),
            metrics: metrics(insight)
          }
        end
      end

      private

      def title(title)
        "Repository insights of #{title}"
      end

      def accessable_message(accessable)
        return '' if accessable

        'Repository has access error'
      end

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
