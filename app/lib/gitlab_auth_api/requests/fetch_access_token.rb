# frozen_string_literal: true

module GitlabAuthApi
  module Requests
    module FetchAccessToken
      def fetch_access_token(client_id:, client_secret:, redirect_url:, code:)
        post(
          path: 'oauth/token',
          params: {
            client_id: client_id,
            client_secret: client_secret,
            redirect_uri: redirect_url,
            code: code,
            grant_type: 'authorization_code'
          },
          headers: { 'Content-type' => 'application/json' }
        )
      end
    end
  end
end
