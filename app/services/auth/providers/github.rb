# frozen_string_literal: true

module Auth
  module Providers
    class Github
      prepend ApplicationService

      def initialize(client: GithubApi::Client)
        @access_token_fetch_client = client.new(url: 'https://github.com')
        @user_fetch_client = client.new
      end

      def call(code:)
        access_token = fetch_access_token(code)
        fetch_user_info(access_token)
        fetch_user_emails(access_token)

        @result = {
          uid: @user['id'],
          provider: 'github',
          login: @user['login'],
          email: @emails.blank? ? nil : @emails[0]['email']
        }
      end

      private

      def fetch_access_token(code)
        response = @access_token_fetch_client.fetch_access_token(
          client_id: credentials.dig(:github_oauth, :development, :client_id),
          client_secret: credentials.dig(:github_oauth, :development, :client_secret),
          code: code
        )
        response.split('&')[0].split('=')[1]
      end

      def fetch_user_info(access_token)
        @user = @user_fetch_client.user(access_token: access_token)
      end

      def fetch_user_emails(access_token)
        @emails = @user_fetch_client.user_emails(access_token: access_token)
      end

      def credentials
        @credentials ||= Rails.application.credentials
      end
    end
  end
end
