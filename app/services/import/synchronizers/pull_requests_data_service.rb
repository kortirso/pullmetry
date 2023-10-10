# frozen_string_literal: true

module Import
  module Synchronizers
    class PullRequestsDataService
      def call(pull_request:)
        fetch_data = fetch_service.call(pull_request: pull_request)
        return unless pull_request.repository.accessable?

        represent_service.call(data: fetch_data[:result])
          .then { |represent_data| save_service.call(pull_request: pull_request, data: represent_data) }
      end

      private

      def fetch_service = raise NotImplementedError
      def represent_service = raise NotImplementedError
      def save_service = raise NotImplementedError
    end
  end
end
