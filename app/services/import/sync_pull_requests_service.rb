# frozen_string_literal: true

module Import
  class SyncPullRequestsService
    prepend ApplicationService

    def initialize(
      fetch_service: Fetchers::PullRequests,
      represent_service: Representers::PullRequests,
      save_service: Savers::PullRequests
    )
      @fetch_service = fetch_service
      @represent_service = represent_service
      @save_service = save_service
    end

    def call(repository:)
      @repository = repository

      @fetch_service.new(repository: @repository).call
        .then { |fetch_data| @represent_service.new.call(data: fetch_data.result) }
        .then { |represent_data| @save_service.call(repository: @repository, data: represent_data) }
    end
  end
end
