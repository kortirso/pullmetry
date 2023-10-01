# frozen_string_literal: true

module GithubApi
  module Requests
    module PullRequestComments
      def pull_request_comments(repository_link:, access_token:, pull_number:, params: {})
        get(
          path: "repos#{URI(repository_link).path}/pulls/#{pull_number}/comments",
          params: params,
          headers: headers(access_token)
        )
      end
    end
  end
end
