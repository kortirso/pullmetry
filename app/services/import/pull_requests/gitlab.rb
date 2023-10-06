# frozen_string_literal: true

module Import
  module PullRequests
    class Gitlab < Import::PullRequestsService
      include Deps[
        fetch_service: 'services.import.fetchers.gitlab.pull_requests',
        represent_service: 'services.import.representers.gitlab.pull_requests'
      ]

      private

      def save_service = Import::Savers::PullRequests.new
    end
  end
end
