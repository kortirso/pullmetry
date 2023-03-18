# frozen_string_literal: true

module Auth
  module Providers
    class Github
      prepend ApplicationService

      def initialize(auth_client: GithubAuthApi::Client.new, api_client: GithubApi::Client.new)
        @auth_client = auth_client
        @api_client = api_client
      end

      def call(code:)
        access_token = fetch_access_token(code)
        return unless access_token

        user = fetch_user_info(access_token)
        email = fetch_user_emails(access_token, user)

        @result = {
          uid: user['id'].to_s,
          provider: 'github',
          login: user['login'],
          email: email
        }
      end

      private

      def fetch_access_token(code)
        @auth_client.fetch_access_token(
          client_id: credentials.dig(:github_oauth, Rails.env.to_sym, :client_id),
          client_secret: credentials.dig(:github_oauth, Rails.env.to_sym, :client_secret),
          code: code
        )['access_token']
      end

      def fetch_user_info(access_token)
        @api_client.user(access_token: access_token)
      end

      def fetch_user_emails(access_token, user)
        return user['email'] if user['email']

        emails = @api_client.user_emails(access_token: access_token)
        emails.dig(0, 'email')
      end

      def credentials
        @credentials ||= Rails.application.credentials
      end
    end
  end
end
