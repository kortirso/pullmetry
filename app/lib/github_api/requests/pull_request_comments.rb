# frozen_string_literal: true

module GithubApi
  module Requests
    module PullRequestComments
      def pull_request_comments(company_name:, repository_name:, pull_number:, access_token:, params: {})
        get(
          path: "repos/#{company_name}/#{repository_name}/pulls/#{pull_number}/comments",
          params: params,
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
