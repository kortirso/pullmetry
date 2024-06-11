# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < ApplicationController
    include Deps[
      attach_identity: 'services.auth.attach_identity',
      fetch_session: 'services.auth.fetch_session',
      generate_token: 'services.auth.generate_token',
      login_user: 'services.auth.login_user',
      github_provider: 'services.auth.providers.github',
      gitlab_provider: 'services.auth.providers.gitlab',
      telegram_provider: 'services.auth.providers.telegram',
      google_provider: 'services.auth.providers.google'
    ]

    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate, only: %i[create]
    before_action :validate_provider, only: %i[create]
    before_action :validate_auth, only: %i[create]

    def create
      auth_result
    end

    def destroy
      fetch_session.call(token: cookies[:pullmetry_token])[:result]&.destroy
      cookies.delete(:pullmetry_token)
      redirect_to root_path
    end

    private

    def validate_provider
      authentication_error if Identity.providers.keys.exclude?(params[:provider])
    end

    def validate_auth
      case params[:provider]
      when Providerable::TELEGRAM then validate_telegram_auth
      else validate_general_auth
      end
    end

    def validate_general_auth
      authentication_error if params[:code].blank? || auth.nil?
    end

    def validate_telegram_auth
      authentication_error if params[:id].blank? || auth.nil?
    end

    def auth_result
      if user
        update_cookies(user)
        accept_invite(user)
        redirect_to(attaching_identity ? profile_path : companies_path)
      else
        redirect_to root_path, flash: { manifesto_username: true }
      end
    end

    def user
      @user ||=
        if attaching_identity
          attach_identity.call(user: current_user, auth: auth)
          current_user
        else
          login_user.call(auth: auth)[:result]
        end
    end

    def auth
      @auth ||= provider_service(params[:provider]).call(params: params)[:result]
    end

    def provider_service(provider)
      case provider
      when Providerable::GITHUB then github_provider
      when Providerable::GITLAB then gitlab_provider
      when Providerable::TELEGRAM then telegram_provider
      when Providerable::GOOGLE then google_provider
      end
    end

    def attaching_identity
      @attaching_identity ||= current_user.present?
    end

    def update_cookies(user)
      cookies[:pullmetry_token] = {
        value: generate_token.call(user: user)[:result],
        expires: 1.week.from_now
      }
    end
  end
end
