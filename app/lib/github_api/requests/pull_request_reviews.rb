# frozen_string_literal: true

module GithubApi
  module Requests
    module PullRequestReviews
      def pull_request_reviews(pull_number:, params: {})
        fetch_data("repos/#{company_name}/#{repository_name}/pulls/#{pull_number}/reviews", params)
      end
    end
  end
end
