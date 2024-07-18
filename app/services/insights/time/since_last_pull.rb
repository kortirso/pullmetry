# frozen_string_literal: true

module Insights
  module Time
    class SinceLastPull < BasisService
      def call(insightable:, pull_requests_ids: [], with_vacations: true)
        super(insightable: insightable, with_vacations: with_vacations)

        data =
          PullRequest
            .created
            .where(id: pull_requests_ids)
            .group(:entity_id)
            .maximum(:pull_created_at)

        users =
          Entity.includes(identity: :user).where(id: data.keys).to_h { |entity| [entity.id, entity.identity&.user] }

        data.each { |entity_id, pull_created_at| handle_pull(users[entity_id], entity_id, pull_created_at) }

        { result: @result.transform_values(&:first) }
      end

      private

      def handle_pull(user, entity_id, pull_created_at)
        update_result_with_value(
          entity_id,
          calculate_seconds(
            pull_created_at,
            DateTime.now,
            user,
            @with_vacations ? user&.vacations : nil
          )
        )
      end
    end
  end
end
