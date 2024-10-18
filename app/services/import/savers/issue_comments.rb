# frozen_string_literal: true

module Import
  module Savers
    class IssueComments
      def call(issue:, data:)
        @issue = issue
        ActiveRecord::Base.transaction do
          destroy_old_comments(data)
          data.each do |payload|
            # proceed only new comments
            next if payload[:external_id].in?(existing_comments)

            create_comment(payload)
          end
        end
      end

      private

      def destroy_old_comments(data)
        @issue.comments.where.not(external_id: data.pluck(:external_id)).destroy_all
      end

      def existing_comments
        @existing_comments ||= @issue.comments.pluck(:external_id)
      end

      def create_comment(payload)
        @issue.comments.create!(payload.slice(:external_id, :comment_created_at))
      end
    end
  end
end
