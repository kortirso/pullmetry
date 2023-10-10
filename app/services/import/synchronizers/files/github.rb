# frozen_string_literal: true

module Import
  module Synchronizers
    module Files
      class Github < Import::Synchronizers::PullRequestsDataService
        include Deps[
          fetch_service: 'services.import.fetchers.github.files',
          represent_service: 'services.import.representers.github.files'
        ]

        private

        def save_service = Import::Savers::Files.new
      end
    end
  end
end
