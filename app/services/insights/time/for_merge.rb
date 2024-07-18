# frozen_string_literal: true

module Insights
  module Time
    class ForMerge < BasisService
      def call(insightable:, pull_requests_ids: [], with_vacations: true)
        super(insightable: insightable, with_vacations: with_vacations)

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
        update_result_with_value(
          entity_id,
          calculate_seconds(
            pull_request.pull_created_at,
            pull_request.pull_merged_at,
            pull_request.entity.identity&.user,
            @with_vacations ? pull_request.entity&.identity&.user&.vacations : nil
          )
        )
      end
    end
  end
end
