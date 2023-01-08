# frozen_string_literal: true

module GithubApi
  module Requests
    module FetchAccessToken
      # BASE_URL = 'https://github.com'
      def fetch_access_token(client_id:, client_secret:, code:)
        post(
          path: 'login/oauth/access_token',
          params: {
            client_id: client_id,
            client_secret: client_secret,
            code: code
          }
        )
      end
    end
  end
end
