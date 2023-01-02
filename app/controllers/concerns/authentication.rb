# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :current_user
  end

  private

  def current_user
    return unless session[:pullmetry_token]

    auth_call = Auth::FetchUserService.call(token: session[:pullmetry_token])
    return if auth_call.failure?

    Current.user ||= auth_call.result
  end

  def authenticate
    return if Current.user

    redirect_to root_path, alert: t('controllers.authentication.permission')
  end
end
