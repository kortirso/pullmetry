# frozen_string_literal: true

module GithubApi
  module Requests
    module PullRequestReviews
      def pull_request_reviews(pull_number:, params: {})
        fetch_data("repos#{repository_path}/pulls/#{pull_number}/reviews", params)
      end
    end
  end
end
