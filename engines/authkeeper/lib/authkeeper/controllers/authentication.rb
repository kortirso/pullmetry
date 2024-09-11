# frozen_string_literal: true

module Authkeeper
  module Controllers
    module Authentication
      extend ActiveSupport::Concern

      included do
        before_action :set_current_user

        helper_method :current_user
      end

      private

      def set_current_user
        access_token = cookies_token.presence || bearer_token.presence || params_token
        return unless access_token

        auth_call = Authkeeper::Container['services.fetch_session'].call(token: access_token)
        return if auth_call[:errors].present?

        @current_user = auth_call[:result].user
      end

      def current_user = @current_user

      def authenticate
        return if current_user

        session[:pullkeeper_fall_back_url] = request.fullpath
        authentication_error
      end

      def authentication_error
        redirect_to root_path, alert: t('controllers.authentication.permission')
      end

      def cookies_token = cookies[access_token_name]
      def params_token = params[access_token_name]

      def bearer_token
        pattern = /^Bearer /
        header = request.headers['Authorization']
        header.gsub(pattern, '') if header&.match(pattern)
      end

      def access_token_name = Authkeeper.configuration.access_token_name
    end
  end
end
