# frozen_string_literal: true

module Insights
  module Time
    class ForIssueClose < BasisService
      def call(insightable:, issues_ids: [])
        super(insightable: insightable)

        result = Issue.closed.where(id: issues_ids).map { |issue| handle_issue(issue) }

        { result: result }
      end

      private

      def handle_issue(issue)
        calculate_seconds(
          issue.opened_at,
          issue.closed_at
        )
      end
    end
  end
end
