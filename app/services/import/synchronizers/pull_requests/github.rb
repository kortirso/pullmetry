# frozen_string_literal: true

module Import
  module Synchronizers
    module PullRequests
      class Github < Import::Synchronizers::PullRequestsService
        include Deps[
          fetch_service: 'services.import.fetchers.github.pull_requests',
          represent_service: 'services.import.representers.github.pull_requests',
          ignore_service: 'services.import.ignore'
        ]

        private

        def save_service = Import::Savers::PullRequests.new
      end
    end
  end
end
