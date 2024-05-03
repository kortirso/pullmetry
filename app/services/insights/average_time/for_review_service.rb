# frozen_string_literal: true

module Insights
  module AverageTime
    class ForReviewService < BasisService
      def call(insightable:, pull_requests_ids: [], with_vacations: true)
        @insightable = insightable
        @with_vacations = with_vacations
        @result = {}

        PullRequests::Review
          .approved
          .accepted
          .joins(:pull_request)
          .where(pull_request_id: pull_requests_ids)
          .where.not(pull_requests: { pull_created_at: nil })
          .find_each { |review| handle_review(review) }

        { result: @result }
      end

      private

      def handle_review(review)
        entity_id = review.entity_id
        update_result_with_total_review_time(
          entity_id,
          calculate_merge_seconds(
            review.pull_request,
            review.pull_request.pull_created_at,
            review.review_created_at,
            @with_vacations ? review.entity.identity&.user&.vacations : nil
          )
        )
      end
    end
  end
end
