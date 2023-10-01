# frozen_string_literal: true

module GithubApi
  module Requests
    module PullRequestReviews
      def pull_request_reviews(repository_link:, access_token:, pull_number:, params: {})
        get(
          path: "repos#{URI(repository_link).path}/pulls/#{pull_number}/reviews",
          params: params,
          headers: headers(access_token)
        )
      end
    end
  end
end
