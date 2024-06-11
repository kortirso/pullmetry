# frozen_string_literal: true

module Auth
  module Providers
    class Google
      include Deps[
        auth_client: 'api.google.auth_client',
        api_client: 'api.google.client'
      ]

      def call(params: {})
        access_token = fetch_access_token(params[:code])
        return { errors: ['Invalid code'] } unless access_token

        user = fetch_user_info(access_token)

        {
          result: {
            uid: user['sub'].to_s,
            provider: 'google',
            email: user['email']
          }
        }
      end

      private

      def fetch_access_token(code)
        auth_client.fetch_access_token(
          client_id: credentials.dig(:google_oauth, Rails.env.to_sym, :client_id),
          client_secret: credentials.dig(:google_oauth, Rails.env.to_sym, :client_secret),
          redirect_uri: credentials.dig(:google_oauth, Rails.env.to_sym, :redirect_url),
          code: code
        )['access_token']
      end

      def fetch_user_info(access_token)
        api_client.user(access_token: access_token)[:body]
      end

      def credentials
        @credentials ||= Rails.application.credentials
      end
    end
  end
end
