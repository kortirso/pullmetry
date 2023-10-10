# frozen_string_literal: true

module Import
  module Fetchers
    module Github
      class Files
        include Deps[fetch_client: 'api.github.client']
        include Import::Concerns::Accessable

        PER_PAGE = 100

        # rubocop: disable Metrics/AbcSize
        def call(pull_request:, result: [])
          repository = pull_request.repository
          request_params = find_default_request_params(repository, pull_request.pull_number)
          page = 1
          loop do
            request_params[:params] = { per_page: PER_PAGE, page: page }
            fetch_result = fetch_client.pull_request_files(**request_params)
            break if !fetch_result[:success] && mark_repository_as_unaccessable(repository)

            mark_repository_as_accessable(repository) unless repository.accessable
            body = fetch_result[:body]
            break if body.blank?

            result.concat(body)
            break if body.size != PER_PAGE

            page += 1
          end
          { result: result }
        end
        # rubocop: enable Metrics/AbcSize

        private

        def find_default_request_params(repository, pull_number)
          {
            repository_link: repository.link,
            access_token: repository.fetch_access_token&.value,
            pull_number: pull_number
          }
        end
      end
    end
  end
end
