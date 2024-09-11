# frozen_string_literal: true

class AddInviteCommand < BaseCommand
  use_contract do
    config.messages.namespace = :invite

    Accesses = Dry::Types['strict.string'].enum(*Invite.accesses.keys)

    params do
      required(:inviteable).filled(type_included_in?: [Company, User])
      required(:email).filled(:string)
      optional(:access).maybe(Accesses)
    end

    rule(:email) do
      key.failure(:invalid_format) unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
    end
  end

  private

  def validate_content(input)
    validate_existing_invite(input)
  end

  def do_persist(input)
    invite = Invite.create!(input)

    InvitesMailer.create_email(id: invite.id).deliver_later

    { result: invite }
  end

  def validate_existing_invite(input)
    'Invite is already sent' if Invite.find_by(input)
  end
end
