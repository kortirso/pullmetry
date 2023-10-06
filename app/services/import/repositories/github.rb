# frozen_string_literal: true

module Import
  module Repositories
    class Github < Import::RepositoriesService
      include Deps[
        sync_pull_requests_service: 'services.import.pull_requests.github',
        sync_comments_service: 'services.import.comments.github',
        sync_reviews_service: 'services.import.reviews.github',
        sync_files_service: 'services.import.files.github',
        update_service: 'services.persisters.repositories.update'
      ]
    end
  end
end
