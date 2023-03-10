# frozen_string_literal: true

module Import
  class SyncReviewsService
    prepend ApplicationService
    include Concerns::Serviceable

    def initialize(pull_request:)
      @pull_request = pull_request
      @provider = pull_request.repository.provider.capitalize
      @service_name = 'Reviews'
    end

    def call
      fetch_service.new(pull_request: @pull_request).call
        .then { |fetch_data| represent_service.new.call(data: fetch_data.result) }
        .then { |represent_data| save_service.call(pull_request: @pull_request, data: represent_data) }
    end
  end
end
