# frozen_string_literal: true

module GithubApi
  module Requests
    module PullRequestFiles
      def pull_request_files(repository_link:, access_token:, pull_number:, params: {})
        get(
          path: "repos#{URI(repository_link).path}/pulls/#{pull_number}/files",
          params: params,
          headers: headers(access_token)
        )
      end
    end
  end
end
