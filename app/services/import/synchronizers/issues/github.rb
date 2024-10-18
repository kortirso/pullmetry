# frozen_string_literal: true

module Import
  module Synchronizers
    module Issues
      class Github < Import::Synchronizers::IssuesService
        include Deps[
          fetch_service: 'services.import.fetchers.github.issues',
          represent_service: 'services.import.representers.github.issues'
        ]

        private

        def save_service = Import::Savers::Issues.new
      end
    end
  end
end
