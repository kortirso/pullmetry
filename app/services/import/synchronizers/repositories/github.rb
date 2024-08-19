# frozen_string_literal: true

module Import
  module Synchronizers
    module Repositories
      class Github < Import::Synchronizers::RepositoriesService
        include Deps[
          sync_pull_requests_service: 'services.import.synchronizers.pull_requests.github',
          sync_comments_service: 'services.import.synchronizers.comments.github',
          sync_reviews_service: 'services.import.synchronizers.reviews.github',
          sync_files_service: 'services.import.synchronizers.files.github',
          change_repository: 'commands.change_repository'
        ]
      end
    end
  end
end
