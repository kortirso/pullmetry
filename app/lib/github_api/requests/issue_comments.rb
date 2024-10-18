# frozen_string_literal: true

module GithubApi
  module Requests
    module IssueComments
      def issue_comments(repository_link:, access_token:, issue_number:, params: {})
        get(
          path: "repos#{URI(repository_link).path}/issues/#{issue_number}/comments",
          params: params,
          headers: headers(access_token)
        )
      end
    end
  end
end
