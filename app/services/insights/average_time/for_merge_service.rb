# frozen_string_literal: true

module Insights
  module AverageTime
    class ForMergeService < BasisService
      prepend ApplicationService

      def call(insightable:, date_from: Insight::FETCH_DAYS_PERIOD, date_to: 0)
        @insightable = insightable
        @result = {}
        PullRequests::Entity
          .author
          .includes(:pull_request)
          .where(
            'pull_request.pull_created_at > ? AND pull_request.pull_created_at < ?',
            date_from.days.ago,
            date_to.days.ago
          )
          .where(pull_request: { repository: insightable.is_a?(Repository) ? insightable : insightable.repositories })
          .where.not(pull_request: { pull_merged_at: nil })
          .each { |pull_requests_entity| handle_entity(pull_requests_entity) }
        update_result_with_average_time
      end

      private

      def handle_entity(pull_requests_entity)
        entity_id = pull_requests_entity.entity_id
        update_result_with_total_review_time(entity_id, calculate_merge_seconds(pull_requests_entity.pull_request))
      end

      def calculate_merge_seconds(pull_request)
        created_at = pull_request.pull_created_at
        merged_at = pull_request.pull_merged_at
        # if PR merge was made before PR changed state from draft to open
        # in such cases time spend for merge is 1 second
        return 1 if created_at >= merged_at
        return merged_at.to_i - created_at.to_i unless @insightable.with_work_time?

        seconds_between_times(
          convert_time(created_at),
          convert_time(merged_at)
        )
      end
    end
  end
end
