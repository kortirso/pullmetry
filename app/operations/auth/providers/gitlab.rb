# frozen_string_literal: true

module Auth
  module Providers
    class Gitlab
      prepend ApplicationService

      def initialize(auth_client: GitlabAuthApi::Client.new, api_client: GitlabApi::Client.new)
        @auth_client = auth_client
        @api_client = api_client
      end

      def call(code:)
        access_token = fetch_access_token(code)
        return unless access_token

        user = fetch_user_info(access_token)

        @result = {
          uid: user['id'].to_s,
          provider: 'gitlab',
          login: user['username'],
          email: user['email']
        }
      end

      private

      def fetch_access_token(code)
        @auth_client.fetch_access_token(
          client_id: credentials.dig(:gitlab_oauth, Rails.env.to_sym, :client_id),
          client_secret: credentials.dig(:gitlab_oauth, Rails.env.to_sym, :client_secret),
          redirect_url: credentials.dig(:gitlab_oauth, Rails.env.to_sym, :redirect_url),
          code: code
        )['access_token']
      end

      def fetch_user_info(access_token)
        @api_client.user(access_token: access_token)[:body]
      end

      def credentials
        @credentials ||= Rails.application.credentials
      end
    end
  end
end
