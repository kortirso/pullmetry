# frozen_string_literal: true

module Persisters
  module Invites
    class AcceptService
      def call(invite:, user:)
        # commento: invites.receiver, invites.code
        invite.update!(receiver: user, code: nil)
        attach_user_to_company(user, invite) if invite.coworker?
      end

      private

      def attach_user_to_company(user, invite)
        ::Companies::User
          .create_with(access: invite.access)
          .find_or_create_by(company: invite.inviteable, user: user, invite: invite)
      end
    end
  end
end
