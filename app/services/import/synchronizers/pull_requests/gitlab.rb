# frozen_string_literal: true

module Import
  module Synchronizers
    module PullRequests
      class Gitlab < Import::Synchronizers::PullRequestsService
        include Deps[
          fetch_service: 'services.import.fetchers.gitlab.pull_requests',
          represent_service: 'services.import.representers.gitlab.pull_requests',
          ignore_service: 'services.import.ignore'
        ]

        private

        def save_service = Import::Savers::PullRequests.new
      end
    end
  end
end
