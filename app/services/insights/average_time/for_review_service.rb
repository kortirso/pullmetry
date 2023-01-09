# frozen_string_literal: true

module Insights
  module AverageTime
    class ForReviewService < BasisService
      prepend ApplicationService

      def call(insightable:)
        @insightable = insightable
        @result = {}
        # TODO: check N+1, maybe there is false positive
        insightable.pull_requests.each do |pull_request|
          pull_request
            .pull_requests_reviews
            .includes(:pull_requests_entity)
            .where(pull_requests_entities: { origin: PullRequests::Entity::REVIEWER }).each do |review|
              # TODO: add penalties for not reviewing
              # https://github.com/kortirso/pullmetry/issues/16
              entity_id = review.pull_requests_entity.entity_id
              update_result_with_total_review_time(entity_id, calculate_review_seconds(review, pull_request))
            end
        end
        update_result_with_average_time
      end

      private

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
