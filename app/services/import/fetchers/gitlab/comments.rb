# frozen_string_literal: true

module Import
  module Fetchers
    module Gitlab
      class Comments
        prepend ApplicationService
        include Concerns::Urlable
        include Import::Concerns::Accessable

        PER_PAGE = 25

        # rubocop: disable Metrics/AbcSize
        def call(pull_request:, fetch_client: GitlabApi::Client)
          @result = []

          repository = pull_request.repository
          fetch_client = fetch_client.new(url: base_url(repository))
          request_params = find_default_request_params(repository, pull_request.pull_number)
          page = 1
          loop do
            # default sorting is asc by id attribute
            # first comes oldest PRs
            request_params[:params] = { per_page: PER_PAGE, page: page }
            result = fetch_client.pull_request_comments(request_params)
            break if !result[:success] && mark_repository_as_unaccessable(repository)

            mark_repository_as_accessable(repository) unless repository.accessable
            body = result[:body]
            break if body.blank?

            @result.concat(body)
            page += 1
          end
        end
        # rubocop: enable Metrics/AbcSize

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
