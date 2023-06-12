# frozen_string_literal: true

module Import
  module Fetchers
    module Gitlab
      class Reviews
        prepend ApplicationService
        include Concerns::Urlable
        include Import::Concerns::Accessable

        def initialize(pull_request:, fetch_client: GitlabApi::Client)
          @repository = pull_request.repository
          @fetch_client = fetch_client.new(url: base_url(@repository), repository: @repository)
          @pull_number = pull_request.pull_number
          @result = []
        end

        def call
          result = @fetch_client.pull_request_reviews(pull_number: @pull_number)
          return if !result[:success] && mark_repository_as_unaccessable

          mark_repository_as_accessable unless @repository.accessable
          @result = result[:body]
        end
      end
    end
  end
end
