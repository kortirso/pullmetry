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
          .where(pull_requests_entities: { origin: PullRequests::Entity::REVIEWER })
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
        return review.review_created_at.to_i - pull_request.pull_created_at.to_i unless @insightable.with_work_time?

        seconds_between_times(
          convert_time(pull_request.pull_created_at),
          convert_time(review.review_created_at)
        )
      end
    end
  end
end
