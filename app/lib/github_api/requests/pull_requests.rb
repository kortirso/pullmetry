# frozen_string_literal: true

module GithubApi
  module Requests
    module PullRequests
      def pull_requests(company_name:, repository_name:, access_token:)
        get(
          path: "repos/#{company_name}/#{repository_name}/pulls",
          params: { state: 'all' },
          headers: {
            'Accept' => 'application/vnd.github+json',
            'Authorization' => "Bearer #{access_token}",
            'X-GitHub-Api-Version' => '2022-11-28'
          }
        )
      end
    end
  end
end
