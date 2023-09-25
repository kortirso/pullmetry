# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user
  end

  private

  def set_current_user
    access_token = session[:pullmetry_token].presence || params[:auth_token].presence
    return unless access_token

    auth_call = Auth::FetchUserOperation.call(token: access_token)
    return if auth_call.failure?

    Current.user ||= auth_call.result
  end

  def current_user
    Current.user
  end

  def authenticate
    return if current_user

    authentication_error
  end

  def authentication_error
    redirect_to root_path, alert: t('controllers.authentication.permission')
  end
end
