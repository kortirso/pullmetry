# frozen_string_literal: true

module Import
  module Synchronizers
    module Repositories
      class Gitlab < Import::Synchronizers::RepositoriesService
        include Deps[
          sync_pull_requests_service: 'services.import.synchronizers.pull_requests.gitlab',
          sync_comments_service: 'services.import.synchronizers.comments.gitlab',
          sync_reviews_service: 'services.import.synchronizers.reviews.gitlab',
          sync_files_service: 'dummy',
          update_service: 'services.persisters.repositories.update'
        ]
      end
    end
  end
end
