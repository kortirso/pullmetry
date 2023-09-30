# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < ApplicationController
    include Deps[
      attach_identity: 'services.auth.attach_identity',
      fetch_session: 'services.auth.fetch_session',
      generate_token: 'services.auth.generate_token',
      login_user: 'services.auth.login_user'
    ]

    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate, only: %i[create]
    before_action :validate_provider, only: %i[create]
    before_action :validate_auth, only: %i[create]

    PROVIDERS = {
      Providerable::GITHUB => ::Auth::Providers::Github,
      Providerable::GITLAB => ::Auth::Providers::Gitlab
    }.freeze

    def create
      if user
        session[:pullmetry_token] = generate_token.call(user: user)[:result]
        redirect_to companies_path, notice: 'Successful login'
      else
        redirect_to root_path, flash: { manifesto_username: true }
      end
    end

    def destroy
      fetch_session.call(token: session[:pullmetry_token])[:result]&.destroy
      session[:pullmetry_token] = nil
      redirect_to root_path, notice: t('controllers.users.sessions.success_destroy')
    end

    private

    def validate_provider
      authentication_error if Identity.providers.keys.exclude?(params[:provider])
    end

    def validate_auth
      authentication_error if params[:code].blank? || auth.nil?
    end

    def user
      @user ||=
        if current_user.nil?
          login_user.call(auth: auth)[:result]
        else
          attach_identity.call(user: current_user, auth: auth)
          current_user
        end
    end

    def auth
      @auth ||= PROVIDERS[params[:provider]].call(code: params[:code]).result
    end
  end
end
