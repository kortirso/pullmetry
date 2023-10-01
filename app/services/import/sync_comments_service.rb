# frozen_string_literal: true

module Import
  class SyncCommentsService
    prepend ApplicationService
    include Concerns::Serviceable

    def initialize(pull_request:)
      @pull_request = pull_request
      @provider = pull_request.repository.provider.capitalize
      @service_name = 'Comments'
    end

    def call
      fetch_data = fetch_service.call(pull_request: @pull_request)
      return unless @pull_request.repository.accessable?

      represent_service.new.call(data: fetch_data.result)
        .then { |represent_data| save_service.call(pull_request: @pull_request, data: represent_data) }
    end
  end
end
