# frozen_string_literal: true

module Authkeeper
  module Providers
    class Gitlab
      include AuthkeeperDeps[
        auth_client: 'api.gitlab.auth_client',
        api_client: 'api.gitlab.client'
      ]

      def call(params: {})
        access_token = fetch_access_token(params[:code])
        return { errors: ['Invalid code'] } unless access_token

        user = fetch_user_info(access_token)

        {
          result: {
            uid: user['id'].to_s,
            provider: 'gitlab',
            login: user['username'],
            email: user['email']
          }
        }
      end

      private

      def fetch_access_token(code)
        auth_client.fetch_access_token(
          client_id: omniauth_config[:client_id],
          client_secret: omniauth_config[:client_secret],
          redirect_url: omniauth_config[:redirect_url],
          code: code
        )['access_token']
      end

      def fetch_user_info(access_token)
        api_client.user(access_token: access_token)[:body]
      end

      def omniauth_config
        @omniauth_config ||= Authkeeper.configuration.omniauth_configs[:gitlab]
      end
    end
  end
end
