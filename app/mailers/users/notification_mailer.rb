# frozen_string_literal: true

module Users
  class NotificationMailer < ApplicationMailer
    def repository_access_error_email(args={})
      @user = User.find_by(id: args[:id])
      return if @user.nil?
      return unless @user.notifications.access_error.first&.value

      mail(to: @user.email, subject: t('mailers.users.notification.repository_access_error_email.subject'))
    end
  end
end
