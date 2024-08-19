# frozen_string_literal: true

module Authkeeper
  module Providers
    class Github
      include AuthkeeperDeps[
        auth_client: 'api.github.auth_client',
        api_client: 'api.github.client'
      ]

      def call(params: {})
        access_token = fetch_access_token(params[:code])
        return { errors: ['Invalid code'] } unless access_token

        user = fetch_user_info(access_token)
        email = fetch_user_emails(access_token, user)

        {
          result: {
            uid: user['id'].to_s,
            provider: 'github',
            login: user['login'],
            email: email
          }
        }
      end

      private

      def fetch_access_token(code)
        auth_client.fetch_access_token(
          client_id: omniauth_config[:client_id],
          client_secret: omniauth_config[:client_secret],
          code: code
        )['access_token']
      end

      def fetch_user_info(access_token)
        api_client.user(access_token: access_token)[:body]
      end

      def fetch_user_emails(access_token, user)
        return user['email'] if user['email']

        emails = api_client.user_emails(access_token: access_token)[:body]
        emails.dig(0, 'email')
      end

      def omniauth_config
        @omniauth_config ||= Authkeeper.configuration.omniauth_configs[:github]
      end
    end
  end
end
