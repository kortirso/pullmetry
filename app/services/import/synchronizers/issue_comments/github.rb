# frozen_string_literal: true

module Import
  module Synchronizers
    module IssueComments
      class Github < Import::Synchronizers::IssuesDataService
        include Deps[
          fetch_service: 'services.import.fetchers.github.issue_comments',
          represent_service: 'services.import.representers.github.issue_comments',
        ]

        private

        def save_service = Import::Savers::IssueComments.new
      end
    end
  end
end
