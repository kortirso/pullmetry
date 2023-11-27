# frozen_string_literal: true

module Import
  module Synchronizers
    class PullRequestsDataService
      def call(pull_request:)
        fetch_data = fetch_service.call(pull_request: pull_request)
        repository = pull_request.repository
        return unless repository.accessable?

        represent_service.call(data: fetch_data[:result])
          .then { |represent_data| ignore_represent_data(repository.company, represent_data) }
          .then { |represent_data| save_service.call(pull_request: pull_request, data: represent_data) }
      end

      private

      def ignore_represent_data(company, represent_data)
        return ignore_service.call(company: company, data: represent_data) if ignore_service

        represent_data
      end

      def fetch_service = raise NotImplementedError
      def represent_service = raise NotImplementedError
      def ignore_service = raise NotImplementedError
      def save_service = raise NotImplementedError
    end
  end
end
