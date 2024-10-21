# frozen_string_literal: true

module Reports
  module Company
    class LongTimeReview
      private

      def no_error_label(insightable)
        "Company #{insightable.title} doesn't have long time review"
      end

      def title(title)
        "Repository long time review of #{title}"
      end

      def grouped_pull_requests(insightable)
        insightable
          .pull_requests
          .opened
          .where(pull_requests: { created_at: ...(insightable.current_config.long_time_review_hours || 48).hours.ago })
          .joins(:repository)
          .order(created_at: :asc)
          .hashable_pluck(:created_at, :pull_number, :repository_id, 'repositories.title')
          .group_by { |element| element[:repository_id] }
      end
    end
  end
end
