# frozen_string_literal: true

module Authkeeper
  class OmniauthCallbacksController < ::ApplicationController
    include AuthkeeperDeps[
      fetch_session: 'services.fetch_session',
      generate_token: 'services.generate_token',
      github_provider: 'services.providers.github',
      gitlab_provider: 'services.providers.gitlab',
      telegram_provider: 'services.providers.telegram',
      google_provider: 'services.providers.google'
    ]

    GITHUB = 'github'
    GITLAB = 'gitlab'
    TELEGRAM = 'telegram'
    GOOGLE = 'google'

    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate, only: %i[create]
    before_action :validate_provider, only: %i[create]
    before_action :validate_auth, only: %i[create]

    def create; end

    def destroy
      fetch_session
        .call(token: cookies[Authkeeper.configuration.access_token_name])[:result]
        &.destroy
      cookies.delete(Authkeeper.configuration.access_token_name)
      redirect_to root_path
    end

    private

    def validate_provider
      authentication_error if Authkeeper.configuration.omniauth_providers.exclude?(params[:provider])
    end

    def validate_auth
      case params[:provider]
      when TELEGRAM then validate_telegram_auth
      else validate_general_auth
      end
    end

    def validate_general_auth
      authentication_error if params[:code].blank? || auth.nil?
    end

    def validate_telegram_auth
      authentication_error if params[:id].blank? || auth.nil?
    end

    def auth
      @auth ||= provider_service(params[:provider]).call(params: params)[:result]
    end

    def provider_service(provider)
      case provider
      when GITHUB then github_provider
      when GITLAB then gitlab_provider
      when TELEGRAM then telegram_provider
      when GOOGLE then google_provider
      end
    end

    def sign_in(user)
      user_session = Authkeeper.configuration.user_session_model.constantize.create!(user: user)
      cookies[Authkeeper.configuration.access_token_name] = {
        value: generate_token.call(user_session: user_session)[:result],
        expires: 1.week.from_now
      }
    end
  end
end
