# frozen_string_literal: true

module GithubAuthApi
  module Requests
    module FetchAccessToken
      def fetch_access_token(client_id:, client_secret:, code:)
        post(
          path: 'login/oauth/access_token',
          params: { client_id: client_id, client_secret: client_secret, code: code },
          headers: { 'Accept' => 'application/vnd.github+json', 'X-GitHub-Api-Version' => '2022-11-28' }
        )
      end
    end
  end
end
