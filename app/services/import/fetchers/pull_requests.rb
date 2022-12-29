# frozen_string_literal: true

module Import
  module Fetchers
    class PullRequests
      prepend ApplicationService

      def initialize(repository:, fetch_client: GithubApi::Client)
        @fetch_client = fetch_client.new(repository: repository)
        @result = []
      end

      def call
        page = 1
        loop do
          # default sorting is desc by created_at attribute
          # first comes newest PRs
          result = @fetch_client.pull_requests(params: { state: 'all', per_page: 25, page: page })
          break if result.blank?

          @result.concat(result)
          # TODO1: in this place @result can be limited by created_at timestamp (for example, PRs for last 30 days)
          # TODO2: in this place @result can be limited by start_from_pull_number, to skip old PRs
          page += 1
        end
      end
    end
  end
end
