# frozen_string_literal: true

module Insights
  module Time
    class ForIssueComment < BasisService
      def call(insightable:, issues_ids: [])
        super(insightable: insightable)

        result =
          Issue
            .where(id: issues_ids)
            .filter_map { |issue| handle_comment(issue.comments.order(comment_created_at: :asc).first) }

        { result: result }
      end

      private

      def handle_comment(comment)
        return unless comment

        calculate_seconds(
          comment.issue.opened_at,
          comment.comment_created_at
        )
      end
    end
  end
end
