# frozen_string_literal: true

module Import
  module Savers
    class Files
      prepend ApplicationService

      def call(pull_request:, data:)
        # commento: pull_requests.changed_loc
        pull_request.update!(changed_loc: data.sum { |payload| payload[:changed_loc] })
      end
    end
  end
end
