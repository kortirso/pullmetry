# frozen_string_literal: true

class AddCompanyCommand < BaseCommand
  include Deps[attach_user_to_company: 'commands.attach_user_to_company']

  use_contract do
    params do
      required(:user).filled(type?: User)
      required(:title).filled(:string)
    end
  end

  private

  def do_persist(input)
    company = ActiveRecord::Base.transaction do
      result = Company.create!(input)
      input[:user].invites.accepted.each do |invite|
        attach_user_to_company.call({ company: result, invite: invite })
      end
    end

    { result: company }
  end
end
