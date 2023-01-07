# frozen_string_literal: true

module GithubApi
  module Requests
    module PullRequestReviewComments
      def pull_request_review_comments(pull_number:, review_id:, params: {})
        fetch_data(
          "repos#{repository_path}/pulls/#{pull_number}/reviews/#{review_id}/comments",
          params
        )
      end
    end
  end
end
