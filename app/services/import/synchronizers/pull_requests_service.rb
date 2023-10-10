# frozen_string_literal: true

module Import
  module Synchronizers
    class PullRequestsService
      def call(repository:)
        fetch_data = fetch_service.call(repository: repository)
        return unless repository.accessable?

        represent_service.call(data: fetch_data[:result])
          .then { |represent_data| save_service.call(repository: repository, data: represent_data) }
      end

      private

      def fetch_service = raise NotImplementedError
      def represent_service = raise NotImplementedError
      def save_service = raise NotImplementedError
    end
  end
end
