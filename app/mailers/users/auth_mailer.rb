# frozen_string_literal: true

module Users
  class AuthMailer < ApplicationMailer
    def confirmation_email(id:)
      @user = User.find_by(id: id)
      return if @user.nil?

      mail(to: @user.email, subject: t('mailers.users.auth.confirmation_email.subject'))
    end

    def password_restore_email(id:)
      @user = User.find_by(id: id)
      return if @user.nil?

      mail(to: @user.email, subject: t('mailers.users.auth.restore_email.subject'))
    end
  end
end
