# frozen_string_literal: true

module Import
  module Fetchers
    class PullRequests
      prepend ApplicationService

      def initialize(repository:, fetch_client: GithubApi::Client)
        @fetch_client = fetch_client.new(repository: repository)
        @start_from_pull_number = repository.start_from_pull_number
        @result = []
      end

      def call
        page = 1
        loop do
          # default sorting is desc by created_at attribute
          # first comes newest PRs
          result = @fetch_client.pull_requests(params: { state: 'all', per_page: 25, page: page })
          result = result.select { |pr| pr['number'] >= @start_from_pull_number } if @start_from_pull_number
          break if result.blank?

          @result.concat(result)
          # TODO: in this place @result can be limited by created_at timestamp (for example, PRs for last 30 days)
          page += 1
        end
      end
    end
  end
end
