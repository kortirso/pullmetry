# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate

    def create
      return redirect_to root_path, flash: { error: 'Access Error' } if params[:code].blank?

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

    def user
      @user ||= ::Auth::LoginUserService.call(auth: auth).result
    end

    def auth
      ::Auth::Providers::Github.call(code: params[:code]).result
    end
  end
end
