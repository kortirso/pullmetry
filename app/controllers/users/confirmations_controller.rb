# frozen_string_literal: true

module Users
  class ConfirmationsController < ApplicationController
    skip_before_action :authenticate
    before_action :find_user
    before_action :check_email_confirmation

    def complete
      Users::CompleteService.call(user: @user)
      redirect_to root_path, notice: t('controllers.users.confirmations.success')
    end

    private

    def find_user
      @user = User.not_confirmed.find_by(email: params[:email])
      return if @user.present?

      failed_complete_confirmation
    end

    def check_email_confirmation
      return if @user.confirmation_token == params[:confirmation_token]

      failed_complete_confirmation
    end

    def failed_complete_confirmation
      render :failed_complete, alert: t('controllers.users.confirmations.failure')
    end
  end
end
