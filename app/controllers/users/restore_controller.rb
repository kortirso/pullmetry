# frozen_string_literal: true

module Users
  class RestoreController < ApplicationController
    skip_before_action :authenticate
    skip_before_action :check_email_confirmation
    before_action :find_user, only: %i[create]

    def new; end

    def create
      Users::RestoreService.call(user: @user)
      redirect_to users_restore_path, notice: t('controllers.users.restore.success')
    end

    private

    def find_user
      @user = User.find_by(email: params[:email]&.downcase)
      return if @user.present?

      failed_restore
    end

    def failed_restore
      redirect_to users_restore_path, alert: t('controllers.users.restore.invalid')
    end
  end
end
