# frozen_string_literal: true

module GithubApi
  module Requests
    module PullRequests
      def pull_requests(params: {})
        fetch_data("repos/#{company_name}/#{repository_name}/pulls", params)
      end
    end
  end
end
