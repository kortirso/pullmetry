# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < ApplicationController
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
        session[:pullmetry_token] = ::Auth::GenerateTokenOperation.call(user: user).result
        redirect_to companies_path, notice: 'Successful login'
      else
        redirect_to root_path, flash: { manifesto_username: true }
      end
    end

    def destroy
      Auth::FetchUserOperation.call(token: session[:pullmetry_token]).session&.destroy
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
          ::Auth::LoginUserOperation.call(auth: auth).result
        else
          ::Auth::AttachIdentityOperation.new.call(user: current_user, auth: auth)
          current_user
        end
    end

    def auth
      @auth ||= PROVIDERS[params[:provider]].call(code: params[:code]).result
    end
  end
end
