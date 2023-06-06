# frozen_string_literal: true

module Import
  module Fetchers
    module Github
      class Reviews
        prepend ApplicationService
        include Import::Concerns::Accessable

        PER_PAGE = 50

        def initialize(pull_request:, fetch_client: GithubApi::Client)
          @repository = pull_request.repository
          @fetch_client = fetch_client.new(repository: @repository)
          @pull_number = pull_request.pull_number
          @result = []
        end

        def call
          page = 1
          loop do
            # default sorting is asc by id attribute
            # first comes oldest PRs
            result =
              @fetch_client.pull_request_reviews(pull_number: @pull_number, params: { per_page: PER_PAGE, page: page })
            break if !result[:success] && mark_repository_as_unaccessable

            body = result[:body]
            break if body.blank?

            @result.concat(body.select { |review| review['state'] == 'APPROVED' })
            break if body.size != PER_PAGE

            page += 1
          end
        end
      end
    end
  end
end
