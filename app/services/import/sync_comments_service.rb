# frozen_string_literal: true

module Import
  class SyncCommentsService
    prepend ApplicationService

    def initialize(
      fetch_service: Fetchers::Comments,
      represent_service: Representers::Comments,
      save_service: Savers::Comments
    )
      @fetch_service = fetch_service
      @represent_service = represent_service
      @save_service = save_service
    end

    def call(pull_request:)
      @pull_request = pull_request

      @fetch_service.new(pull_request: @pull_request).call
        .then { |fetch_data| @represent_service.new.call(data: fetch_data.result) }
        .then { |represent_data| @save_service.call(pull_request: @pull_request, data: represent_data) }
    end
  end
end
