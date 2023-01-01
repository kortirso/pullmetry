# frozen_string_literal: true

module Insights
  class CalculateAverageReviewTimeService
    prepend ApplicationService

    def call(insightable:)
      @result = {}
      insightable.pull_requests.includes(pull_requests_reviews: :pull_requests_entity).each do |pull_request|
        created_at = pull_request.pull_created_at.to_i

        pull_request.pull_requests_reviews.each do |review|
          # TODO: not working time between created and review time can be substracted from review_seconds
          # https://github.com/kortirso/pullmetry/issues/9
          # https://github.com/kortirso/pullmetry/issues/16
          review_seconds = review.review_created_at.to_i - created_at
          entity_id = review.pull_requests_entity.entity_id
          update_result_with_total_review_time(entity_id, review_seconds)
        end
      end
      update_result_with_average_time
    end

    private

    def update_result_with_total_review_time(entity_id, review_seconds)
      @result[entity_id] = @result.key?(entity_id) ? @result[entity_id].push(review_seconds) : [review_seconds]
    end

    def update_result_with_average_time
      @result.transform_values! { |value| value.sum / value.size }
    end
  end
end
