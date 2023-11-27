# frozen_string_literal: true

module Import
  module Synchronizers
    module Reviews
      class Github < Import::Synchronizers::PullRequestsDataService
        include Deps[
          fetch_service: 'services.import.fetchers.github.reviews',
          represent_service: 'services.import.representers.github.reviews',
          ignore_service: 'services.import.ignore'
        ]

        private

        def save_service = Import::Savers::Reviews.new
      end
    end
  end
end
