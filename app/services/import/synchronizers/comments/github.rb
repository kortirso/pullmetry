# frozen_string_literal: true

module Import
  module Synchronizers
    module Comments
      class Github < Import::Synchronizers::PullRequestsDataService
        include Deps[
          fetch_service: 'services.import.fetchers.github.comments',
          represent_service: 'services.import.representers.github.comments',
          ignore_service: 'services.import.ignore'
        ]

        private

        def save_service = Import::Savers::Comments.new
      end
    end
  end
end
