# frozen_string_literal: true

module Import
  module Synchronizers
    module Reviews
      class Gitlab < Import::Synchronizers::PullRequestsDataService
        include Deps[
          fetch_service: 'services.import.fetchers.gitlab.reviews',
          represent_service: 'services.import.representers.gitlab.reviews',
          ignore_service: 'services.import.ignore'
        ]

        private

        def save_service = Import::Savers::Reviews.new
      end
    end
  end
end
