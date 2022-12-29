# frozen_string_literal: true

module Import
  module Savers
    class PullRequests
      prepend ApplicationService

      def call(repository:, data:)
        ap data
      end
    end
  end
end
