# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate
    skip_before_action :check_email_confirmation

    def create
      auth = request.env['omniauth.auth']
      return redirect_to root_path, flash: { error: 'Access Error' } if auth.nil?

      user = ::Auth::LoginUserService.call(auth: auth).result
      if user
        session[:pullmetry_token] = ::Auth::GenerateTokenService.call(user: user).result
        redirect_to companies_path
      else
        redirect_to root_path, flash: { manifesto_username: true }
      end
    end
  end
end
