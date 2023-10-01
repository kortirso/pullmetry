# frozen_string_literal: true

module Import
  class SyncPullRequestsService
    prepend ApplicationService
    include Concerns::Serviceable

    def initialize(repository:)
      @repository = repository
      @provider = repository.provider.capitalize
      @service_name = 'PullRequests'
    end

    def call
      fetch_data = fetch_service.call(repository: @repository)
      return unless @repository.accessable?

      represent_service.new.call(data: fetch_data.result)
        .then { |represent_data| save_service.call(repository: @repository, data: represent_data) }
    end
  end
end
