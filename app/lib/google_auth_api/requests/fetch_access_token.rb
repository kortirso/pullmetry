# frozen_string_literal: true

module GoogleAuthApi
  module Requests
    module FetchAccessToken
      def fetch_access_token(client_id:, client_secret:, code:, redirect_uri:)
        post(
          path: 'oauth2/v4/token',
          params: {
            grant_type: 'authorization_code',
            client_id: client_id,
            client_secret: client_secret,
            code: code,
            redirect_uri: redirect_uri
          },
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
        )
      end
    end
  end
end
