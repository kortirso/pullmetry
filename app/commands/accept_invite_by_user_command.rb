# frozen_string_literal: true

class AcceptInviteByUserCommand < BaseCommand
  use_contract do
    params do
      required(:invite).filled(type?: Invite)
      required(:user).filled(type?: User)
    end
  end

  private

  def do_persist(input)
    ActiveRecord::Base.transaction do
      input[:invite].update!(receiver: input[:user], code: nil)
      attach_user_to_user(input) if input[:invite].coowner?
      attach_user_to_company(input[:invite].inviteable, input[:user], input[:invite]) if input[:invite].coworker?
    end

    { result: input[:invite].reload }
  end

  def attach_user_to_user(input)
    input[:invite].inviteable.companies.each do |company|
      attach_user_to_company(company, input[:user], input[:invite])
    end
  end

  def attach_user_to_company(company, user, invite)
    ::Companies::User
      .create_with(access: invite.access)
      .find_or_create_by(company: company, user: user, invite: invite)
  end
end
