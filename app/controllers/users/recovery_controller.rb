# frozen_string_literal: true

module Users
  class RecoveryController < ApplicationController
    skip_before_action :authenticate
    skip_before_action :check_email_confirmation
    before_action :find_user
    before_action :check_recovery_token

    def new; end

    def create
      service_call = Users::UpdateService.call(user: @user, params: user_params)
      service_call.success? ? success_recovery_response : failed_recovery(service_call.errors)
    end

    private

    def success_recovery_response
      @user.regenerate_restore_token
      redirect_to users_login_path, notice: t('controllers.users.recovery.success')
    end

    def find_user
      @user = User.find_by(email: params[:email])
      return if @user.present?

      failed_recovery
    end

    def check_recovery_token
      return if @user.restore_token == params[:restore_token]

      failed_recovery
    end

    def failed_recovery(alert=t('controllers.users.recovery.invalid'))
      redirect_to users_recovery_path(email: params[:email], restore_token: params[:restore_token]), alert: alert
    end

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
  end
end
