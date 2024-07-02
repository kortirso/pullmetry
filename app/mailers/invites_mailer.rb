# frozen_string_literal: true

class InvitesMailer < ApplicationMailer
  def create_email(args={})
    @invite = Invite.find_by(id: args[:id])
    return if @invite.nil?
    return if @invite.email.blank?

    @subject_email = @invite.coowner? ? @invite.inviteable.email : @invite.inviteable.user.email

    mail(
      to: @invite.email,
      subject: "Invitation from #{@subject_email} to PullKeeper"
    )
  end
end
