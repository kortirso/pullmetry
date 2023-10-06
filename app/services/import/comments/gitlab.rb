# frozen_string_literal: true

module Import
  module Comments
    class Gitlab < Import::PullRequestsDataService
      include Deps[
        fetch_service: 'services.import.fetchers.gitlab.comments',
        represent_service: 'services.import.representers.gitlab.comments'
      ]

      private

      def save_service = Import::Savers::Comments.new
    end
  end
end
