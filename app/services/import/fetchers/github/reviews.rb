# frozen_string_literal: true

module Import
  module Fetchers
    module Github
      class Reviews
        prepend ApplicationService

        PER_PAGE = 50

        def initialize(pull_request:, fetch_client: GithubApi::Client)
          @fetch_client = fetch_client.new(repository: pull_request.repository)
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
            break if result.blank?

            @result.concat(result.select { |review| review['state'] == 'APPROVED' })
            break if result.size != PER_PAGE

            page += 1
          end
        end
      end
    end
  end
end
