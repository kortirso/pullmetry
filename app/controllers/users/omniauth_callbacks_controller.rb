# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate
    before_action :validate_provider, only: %i[create]
    before_action :validate_auth, only: %i[create]

    PROVIDERS = {
      Providerable::GITHUB => ::Auth::Providers::Github,
      Providerable::GITLAB => ::Auth::Providers::Gitlab
    }.freeze

    def create
      if user
        session[:pullmetry_token] = ::Auth::GenerateTokenService.call(user: user).result
        redirect_to companies_path, notice: 'Successful login'
      else
        redirect_to root_path, flash: { manifesto_username: true }
      end
    end

    def destroy
      # TODO: Here can be destroying token from database
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
      @user ||= ::Auth::LoginUserService.call(auth: auth).result
    end

    def auth
      @auth ||= PROVIDERS[params[:provider]].call(code: params[:code]).result
    end
  end
end
