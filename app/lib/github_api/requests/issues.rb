# frozen_string_literal: true

module GithubApi
  module Requests
    module Issues
      def issues(repository_link:, access_token:, params: {})
        get(
          path: "repos#{URI(repository_link).path}/issues",
          params: params,
          headers: headers(access_token)
        )
      end
    end
  end
end
