# frozen_string_literal: true

class AddInviteCommand < BaseCommand
  use_contract do
    Accesses = Dry::Types['strict.string'].enum(*Invite.accesses.keys)

    params do
      required(:inviteable).filled(type?: ApplicationRecord)
      required(:email).filled(:string)
      optional(:access).maybe(Accesses)
    end

    rule(:email) do
      key.failure(:invalid_format) unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
    end
  end

  private

  def do_validate(input)
    errors = super
    return errors if errors.present?

    error = validate_inviteable_type(input) || validate_existing_invite(input)
    [error] if error
  end

  def do_persist(input)
    invite = Invite.create!(input)

    InvitesMailer.create_email(id: invite.id).deliver_later

    { result: invite }
  end

  def validate_inviteable_type(input)
    return if input[:inviteable].class.name.in?(Invite::INVITEABLE_TYPES)

    'Inviteable is not supported'
  end

  def validate_existing_invite(input)
    'Invite is already sent' if Invite.find_by(input)
  end
end
