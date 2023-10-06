# frozen_string_literal: true

module Import
  module Comments
    class Github < Import::PullRequestsDataService
      include Deps[
        fetch_service: 'services.import.fetchers.github.comments',
        represent_service: 'services.import.representers.github.comments'
      ]

      private

      def save_service = Import::Savers::Comments.new
    end
  end
end
