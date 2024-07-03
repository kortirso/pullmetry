# frozen_string_literal: true

module DiscordWebhooks
  module Company
    class LongTimeReviewReportPayload
      include Deps[time_representer: 'services.converters.seconds_to_text']

      def call(insightable:)
        grouped_pull_requests = grouped_pull_requests(insightable)
        return "Company #{insightable.title} doesn't have long time review" if grouped_pull_requests.empty?

        grouped_pull_requests.values.map { |pull_requests|
          [
            title(pull_requests.first[:repositories_title]),
            pull_requests.map { |pull_request| metrics(pull_request) }.join("\n")
          ].join("\n")
        }.join("\n\n")
      end

      private

      def title(title)
        "**Repository long time review of #{title}**"
      end

      def metrics(pull_request)
        in_progress_time = time_representer.call(value: DateTime.now.to_i - pull_request[:created_at].to_i)

        [
          "**Pull number:** #{pull_request[:pull_number]}",
          "**In review time:** #{in_progress_time}"
        ].join(', ')
      end

      def grouped_pull_requests(insightable)
        insightable
          .pull_requests
          .opened
          .where(pull_requests: { created_at: ...(insightable.configuration.long_time_review_hours || 48).hours.ago })
          .joins(:repository)
          .order(created_at: :asc)
          .hashable_pluck(:created_at, :pull_number, :repository_id, 'repositories.title')
          .group_by { |element| element[:repository_id] }
      end
    end
  end
end
