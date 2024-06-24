# frozen_string_literal: true

module Persisters
  module Invites
    class AcceptService
      def call(invite:, user:)
        invite.update!(receiver: user, email: nil, code: nil)
        attach_user_to_company(invite.inviteable, user, invite, invite.access) if invite.coworker?
      end

      private

      def attach_user_to_company(company, user, invite, access)
        ::Companies::User.find_or_create_by(
          company: company,
          user: user,
          invite: invite,
          access: access
        )
      end
    end
  end
end
