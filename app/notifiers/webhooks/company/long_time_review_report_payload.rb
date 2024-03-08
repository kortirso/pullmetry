# frozen_string_literal: true

module Webhooks
  module Company
    class LongTimeReviewReportPayload
      def call(insightable:)
        return "Company #{insightable.title} doesn't have long time review" if grouped_pull_requests(insightable).empty?

        grouped_pull_requests(insightable).values.map do |pull_requests|
          {
            title: title(pull_requests.first[:repositories_title]),
            metrics: pull_requests.map { |pull_request| metrics(pull_request) }
          }
        end
      end

      private

      def title(title)
        "Repository long time review of #{title}"
      end

      def metrics(pull_request)
        {
          pull_number: pull_request[:pull_number],
          in_progress_seconds: DateTime.now.to_i - pull_request[:created_at].to_i
        }
      end

      def grouped_pull_requests(insightable)
        insightable
          .pull_requests
          .opened
          .where('pull_requests.created_at < ?', (insightable.configuration.long_time_review_hours || 48).hours.ago)
          .joins(:repository)
          .order(created_at: :asc)
          .hashable_pluck(:created_at, :pull_number, :repository_id, 'repositories.title')
          .group_by { |element| element[:repository_id] }
      end
    end
  end
end
