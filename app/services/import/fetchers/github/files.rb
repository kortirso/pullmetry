# frozen_string_literal: true

module Import
  module Fetchers
    module Github
      class Files
        prepend ApplicationService
        include Import::Concerns::Accessable

        PER_PAGE = 100

        def initialize(pull_request:, fetch_client: GithubApi::Client)
          @repository = pull_request.repository
          @fetch_client = fetch_client.new(repository: @repository)
          @pull_number = pull_request.pull_number
          @result = []
        end

        def call
          page = 1
          loop do
            result =
              @fetch_client.pull_request_files(pull_number: @pull_number, params: { per_page: PER_PAGE, page: page })
            break if !result[:success] && mark_repository_as_unaccessable

            mark_repository_as_accessable unless @repository.accessable
            body = result[:body]
            break if body.blank?

            @result.concat(body)
            break if body.size != PER_PAGE

            page += 1
          end
        end
      end
    end
  end
end
