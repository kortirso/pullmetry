# frozen_string_literal: true

module Import
  module Repositories
    class Gitlab < Import::RepositoriesService
      include Deps[
        sync_pull_requests_service: 'services.import.pull_requests.gitlab',
        sync_comments_service: 'services.import.comments.gitlab',
        sync_reviews_service: 'services.import.reviews.gitlab',
        sync_files_service: 'dummy',
        update_service: 'services.persisters.repositories.update'
      ]
    end
  end
end
