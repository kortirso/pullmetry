# frozen_string_literal: true

module Reports
  module Company
    class RepositoryInsights
      private

      def no_error_label(insightable)
        "Company #{insightable.title} doesn't have repository insights"
      end

      def title(title)
        "Repository insights of #{title}"
      end

      def accessable_message(accessable)
        return '' if accessable

        'Repository has access error'
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
