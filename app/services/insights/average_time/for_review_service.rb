# frozen_string_literal: true

module Insights
  module AverageTime
    class ForReviewService < BasisService
      prepend ApplicationService

      def call(insightable:, date_from: Insight::FETCH_DAYS_PERIOD, date_to: 0)
        @insightable = insightable
        @result = {}
        PullRequests::Review
          .includes(pull_requests_entity: :pull_request)
          .where(
            'pull_requests.pull_created_at > ? AND pull_requests.pull_created_at < ?',
            date_from.days.ago,
            date_to.days.ago
          )
          .where(pull_requests: { repository: insightable.is_a?(Repository) ? insightable : insightable.repositories })
          .each { |review| handle_review(review) }
        update_result_with_average_time
      end

      private

      def handle_review(review)
        entity_id = review.pull_requests_entity.entity_id
        update_result_with_total_review_time(
          entity_id,
          calculate_review_seconds(review, review.pull_requests_entity.pull_request)
        )
      end

      def calculate_review_seconds(review, pull_request)
        created_at = pull_request.pull_created_at
        reviewed_at = review.review_created_at
        # if PR merge was made before PR changed state from draft to open
        # in such cases time spend for merge is 1 second
        return 1 if created_at >= reviewed_at
        return reviewed_at.to_i - created_at.to_i unless @insightable.with_work_time?

        seconds_between_times(
          convert_time(created_at),
          convert_time(reviewed_at)
        )
      end
    end
  end
end
