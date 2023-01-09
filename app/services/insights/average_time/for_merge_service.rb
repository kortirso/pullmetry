# frozen_string_literal: true

module Insights
  module AverageTime
    class ForMergeService < BasisService
      prepend ApplicationService

      def call(insightable:)
        @insightable = insightable
        @result = {}
        insightable.pull_requests.merged.each do |pull_request|
          entity_id = pull_request.pull_requests_entities.author.first.entity_id
          update_result_with_total_review_time(entity_id, calculate_merge_seconds(pull_request))
        end
        update_result_with_average_time
      end

      private

      def calculate_merge_seconds(pull_request)
        return pull_request.pull_merged_at.to_i - pull_request.pull_created_at.to_i unless @insightable.with_work_time?

        seconds_between_times(
          convert_time(pull_request.pull_created_at),
          convert_time(pull_request.pull_merged_at)
        )
      end
    end
  end
end
