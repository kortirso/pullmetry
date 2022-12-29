# frozen_string_literal: true

module GithubApi
  module Requests
    module PullRequestComments
      def pull_request_comments(pull_id:, params: {})
        fetch_data("repos/#{company_name}/#{repository_name}/pulls/#{pull_id}/comments", params)
      end
    end
  end
end
