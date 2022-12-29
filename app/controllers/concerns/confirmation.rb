# frozen_string_literal: true

module Confirmation
  extend ActiveSupport::Concern

  private

  def check_email_confirmation
    return if Current.user&.confirmed?

    redirect_to users_confirm_path, alert: t('controllers.confirmation.permission')
  end
end
