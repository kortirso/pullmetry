# frozen_string_literal: true

module GithubApi
  module Requests
    module PullRequestFiles
      def pull_request_files(pull_number:, params: {})
        fetch_data("repos#{repository_path}/pulls/#{pull_number}/files", params)
      end
    end
  end
end
