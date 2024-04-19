# frozen_string_literal: true

module Insights
  module AverageTime
    class ForMergeService < BasisService
      def call(insightable:, pull_requests_ids: [], with_vacations: true)
        @insightable = insightable
        @with_vacations = with_vacations
        @result = {}

        PullRequest
          .created
          .merged
          .where(id: pull_requests_ids)
          .find_each { |pull_request| handle_entity(pull_request) }

        { result: @result }
      end

      private

      def handle_entity(pull_request)
        entity_id = pull_request.entity_id
        update_result_with_total_review_time(
          entity_id,
          calculate_merge_seconds(
            pull_request,
            pull_request.pull_created_at,
            pull_request.pull_merged_at,
            @with_vacations ? pull_request.entity&.identity&.user&.vacations : nil
          )
        )
      end
    end
  end
end
