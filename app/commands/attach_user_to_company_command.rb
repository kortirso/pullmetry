# frozen_string_literal: true

class AttachUserToCompanyCommand < BaseCommand
  use_contract do
    params do
      required(:company).filled(type?: Company)
      required(:invite).filled(type?: Invite)
    end
  end

  private

  def do_persist(input)
    companies_user = ::Companies::User
      .create_with(access: input[:invite].access)
      .find_or_create_by(company: input[:company], user: input[:invite].receiver, invite: input[:invite])

    { result: companies_user }
  end
end
