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

    auth_call = Pullmetry::Container['services.auth.fetch_session'].call(token: access_token)
    return if auth_call[:errors].present?

    Current.user ||= auth_call[:result].user
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
