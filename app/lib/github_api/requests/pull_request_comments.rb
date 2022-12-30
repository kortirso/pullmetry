# frozen_string_literal: true

module GithubApi
  module Requests
    module PullRequestComments
      def pull_request_comments(pull_number:, params: {})
        fetch_data("repos/#{company_name}/#{repository_name}/pulls/#{pull_number}/comments", params)
      end
    end
  end
end
