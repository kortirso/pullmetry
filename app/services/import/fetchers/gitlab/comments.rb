# frozen_string_literal: true

module Import
  module Fetchers
    module Gitlab
      class Comments
        prepend ApplicationService
        include Concerns::Urlable

        def initialize(pull_request:, fetch_client: GitlabApi::Client)
          @fetch_client = fetch_client.new(url: base_url(pull_request.repository), repository: pull_request.repository)
          @pull_number = pull_request.pull_number
          @result = []
        end

        def call
          page = 1
          loop do
            # default sorting is asc by id attribute
            # first comes oldest PRs
            result =
              @fetch_client.pull_request_comments(pull_number: @pull_number, params: { per_page: 25, page: page })
            break if result.blank?

            @result.concat(result)
            page += 1
          end
        end
      end
    end
  end
end
