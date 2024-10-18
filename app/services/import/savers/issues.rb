# frozen_string_literal: true

module Import
  module Savers
    class Issues
      ALLOWED_ATTRIBUTES = %i[issue_number opened_at closed_at].freeze

      def call(repository:, data:)
        @repository = repository
        ActiveRecord::Base.transaction do
          destroy_old_issues(data)
          data.each do |payload|
            # proceed only open issues
            next if reject_issue?(payload)

            save_issue(payload)
          end
        end
      end

      private

      def destroy_old_issues(data)
        @repository
          .issues
          .where.not(issue_number: data.pluck(:issue_number))
          .destroy_all
      end

      def reject_issue?(payload)
        payload[:issue_number].in?(existing_closed_issues)
      end

      def existing_closed_issues
        @existing_closed_issues ||= @repository.issues.closed.pluck(:issue_number)
      end

      def save_issue(payload)
        issue =
          @repository
            .issues
            .find_or_initialize_by(issue_number: payload.delete(:issue_number))
        issue.update!(payload.slice(*ALLOWED_ATTRIBUTES))
      end
    end
  end
end
