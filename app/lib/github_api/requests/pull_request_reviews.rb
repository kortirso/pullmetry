# frozen_string_literal: true

module GithubApi
  module Requests
    module PullRequestReviews
      def pull_request_reviews(pull_id:, params: {})
        fetch_data("repos/#{company_name}/#{repository_name}/pulls/#{pull_id}/reviews", params)
      end
    end
  end
end
