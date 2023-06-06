# frozen_string_literal: true

module Insights
  module AverageTime
    class ForMergeService < BasisService
      prepend ApplicationService

      def call(insightable:, date_from: Insight::FETCH_DAYS_PERIOD, date_to: 0)
        @insightable = insightable
        @result = {}
        PullRequest
          .where(
            'pull_created_at > ? AND pull_created_at < ?',
            date_from.days.ago,
            date_to.days.ago
          )
          .where(repository: insightable.is_a?(Repository) ? insightable : insightable.repositories)
          .where.not(pull_merged_at: nil)
          .each { |pull_request| handle_entity(pull_request) }
        update_result_with_average_time
      end

      private

      def handle_entity(pull_request)
        entity_id = pull_request.entity_id
        update_result_with_total_review_time(entity_id, calculate_merge_seconds(pull_request))
      end

      def calculate_merge_seconds(pull_request)
        created_at = pull_request.pull_created_at
        merged_at = pull_request.pull_merged_at
        # if PR merge was made before PR changed state from draft to open
        # in such cases time spend for merge is 1 second
        return 1 if created_at >= merged_at
        return merged_at.to_i - created_at.to_i unless @insightable.with_work_time?

        find_using_work_time(pull_request)
        seconds_between_times(
          convert_time(created_at),
          convert_time(merged_at),
          pull_request.entity&.identity&.user&.vacations
        )
      end
    end
  end
end
