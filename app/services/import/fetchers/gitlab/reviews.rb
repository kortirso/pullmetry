# frozen_string_literal: true

module Import
  module Fetchers
    module Gitlab
      class Reviews
        include Concerns::Urlable
        include Import::Concerns::Accessable

        def call(pull_request:, fetch_client: GitlabApi::Client)
          repository = pull_request.repository
          fetch_client = fetch_client.new(url: base_url(repository))
          fetch_result = fetch_client.pull_request_reviews(
            **find_default_request_params(repository, pull_request.pull_number)
          )
          return if !fetch_result[:success] && mark_repository_as_unaccessable(repository)

          mark_repository_as_accessable(repository) unless repository.accessable
          { result: fetch_result[:body] }
        end

        private

        def find_default_request_params(repository, pull_number)
          {
            external_id: repository.external_id,
            access_token: repository.fetch_access_token&.value,
            pull_number: pull_number
          }
        end
      end
    end
  end
end
