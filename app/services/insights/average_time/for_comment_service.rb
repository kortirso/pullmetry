# frozen_string_literal: true

module Insights
  module AverageTime
    class ForCommentService < BasisService
      def call(insightable:, pull_requests_ids: [], with_vacations: true)
        @insightable = insightable
        @with_vacations = with_vacations
        @result = {}

        PullRequest
          .created
          .where(id: pull_requests_ids)
          .find_each do |pull_request|
            comment = pull_request.pull_requests_comments.order(comment_created_at: :asc).first
            review = pull_request.pull_requests_reviews.approved.order(review_created_at: :asc).first

            handle_comment_or_review(comment, review)
          end

        { result: @result }
      end

      private

      # rubocop: disable Metrics/CyclomaticComplexity
      def handle_comment_or_review(comment, review)
        return handle_comment(comment) if comment && review.nil?
        return handle_review(review) if comment.nil? && review
        return if comment.nil? && review.nil?
        return handle_comment(comment) if comment.comment_created_at <= review.review_created_at

        handle_review(review)
      end
      # rubocop: enable Metrics/CyclomaticComplexity

      def handle_comment(comment)
        entity_id = comment.entity_id
        update_result_with_total_review_time(
          entity_id,
          calculate_merge_seconds(
            comment.pull_request,
            comment.pull_request.pull_created_at,
            comment.comment_created_at,
            @with_vacations ? comment.pull_request.entity&.identity&.user&.vacations : nil
          )
        )
      end

      def handle_review(review)
        entity_id = review.entity_id
        update_result_with_total_review_time(
          entity_id,
          calculate_merge_seconds(
            review.pull_request,
            review.pull_request.pull_created_at,
            review.review_created_at,
            @with_vacations ? review.entity.identity&.user&.vacations : nil
          )
        )
      end
    end
  end
end
