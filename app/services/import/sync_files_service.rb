# frozen_string_literal: true

module Import
  class SyncFilesService
    prepend ApplicationService
    include Concerns::Serviceable

    ALLOWED_PROVIDERS = [
      Providerable::GITHUB.capitalize
    ].freeze

    def initialize(pull_request:)
      @pull_request = pull_request
      @provider = pull_request.repository.provider.capitalize
      @service_name = 'Files'
    end

    def call
      return if ALLOWED_PROVIDERS.exclude?(@provider)

      fetch_data = fetch_service.new(pull_request: @pull_request).call
      return unless @pull_request.repository.accessable?

      represent_service.new.call(data: fetch_data.result)
        .then { |represent_data| save_service.call(pull_request: @pull_request, data: represent_data) }
    end
  end
end
