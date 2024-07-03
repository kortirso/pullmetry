# frozen_string_literal: true

module Reports
  module Company
    module Telegram
      class LongTimeReview < Reports::Company::LongTimeReview
        include Deps[time_representer: 'services.converters.seconds_to_text']

        def call(insightable:)
          grouped_pull_requests = grouped_pull_requests(insightable)
          return no_error_label(insightable) if grouped_pull_requests.empty?

          grouped_pull_requests.values.map { |pull_requests|
            [
              title(pull_requests.first[:repositories_title]),
              pull_requests.map { |pull_request| metrics(pull_request) }.join("\n")
            ].join("\n")
          }.join("\n\n")
        end

        private

        def metrics(pull_request)
          in_progress_time = time_representer.call(value: DateTime.now.to_i - pull_request[:created_at].to_i)

          [
            "Pull number: #{pull_request[:pull_number]}",
            "In review time: #{in_progress_time}"
          ].join(', ')
        end
      end
    end
  end
end
