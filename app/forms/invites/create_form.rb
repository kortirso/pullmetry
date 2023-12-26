# frozen_string_literal: true

module Invites
  class CreateForm
    include Deps[validator: 'validators.invite']

    def call(inviteable:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      existing_invite = inviteable.invites.find_by(email: params[:email])
      return { errors: ['Invite is already sent'] } if existing_invite

      result = inviteable.invites.create!(params)
      InvitesMailer.create_email(id: result.id).deliver_later

      { result: result }
    end
  end
end
