# frozen_string_literal: true

module Companies
  class CreateForm
    include Deps[validator: 'validators.companies.create']

    def call(user:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      result = user.companies.create!(params)
      user.invites.accepted.each do |invite|
        attach_user_to_company(result, invite.receiver, invite)
      end

      { result: result }
    end

    private

    def attach_user_to_company(company, user, invite)
      ::Companies::User
        .create_with(access: invite.access)
        .find_or_create_by(company: company, user: user, invite: invite)
    end
  end
end
