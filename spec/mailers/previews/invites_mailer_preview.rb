# frozen_string_literal: true

# Preview all emails at http://localhost:5000/rails/mailers/invites_mailer
class InvitesMailerPreview < ActionMailer::Preview
  def create_email
    InvitesMailer.create_email(id: Invite.last.id)
  end
end
