# frozen_string_literal: true

module Persisters
  module Invites
    class AcceptService
      def call(invite:, user:)
        # commento: invites.receiver, invites.code
        invite.update!(receiver: user, code: nil)
        attach_user_to_user(user, invite) if invite.coowner?
        attach_user_to_company(invite.inviteable, user, invite) if invite.coworker?
      end

      private

      def attach_user_to_user(user, invite)
        invite.inviteable.companies.each do |company|
          attach_user_to_company(company, user, invite)
        end
      end

      def attach_user_to_company(company, user, invite)
        ::Companies::User
          .create_with(access: invite.access)
          .find_or_create_by(company: company, user: user, invite: invite)
      end
    end
  end
end
