# frozen_string_literal: true

module Reports
  module Company
    module Custom
      class LongTimeReview < Reports::Company::LongTimeReview
        def call(insightable:)
          grouped_pull_requests = grouped_pull_requests(insightable)
          return no_error_label(insightable) if grouped_pull_requests.empty?

          grouped_pull_requests.values.map do |pull_requests|
            {
              title: title(pull_requests.first[:repositories_title]),
              metrics: pull_requests.map { |pull_request| metrics(pull_request) }
            }
          end
        end

        private

        def metrics(pull_request)
          {
            pull_number: pull_request[:pull_number],
            in_progress_seconds: DateTime.now.to_i - pull_request[:created_at].to_i
          }
        end
      end
    end
  end
end
