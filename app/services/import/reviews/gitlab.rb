# frozen_string_literal: true

module Import
  module Reviews
    class Gitlab < Import::PullRequestsDataService
      include Deps[
        fetch_service: 'services.import.fetchers.gitlab.reviews',
        represent_service: 'services.import.representers.gitlab.reviews'
      ]

      private

      def save_service = Import::Savers::Reviews.new
    end
  end
end
