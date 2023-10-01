# frozen_string_literal: true

module GithubApi
  module Requests
    module PullRequests
      def pull_requests(repository_link:, access_token:, params: {})
        get(
          path: "repos#{URI(repository_link).path}/pulls",
          params: params,
          headers: headers(access_token)
        )
      end
    end
  end
end
