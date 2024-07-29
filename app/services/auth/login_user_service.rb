# frozen_string_literal: true

module Auth
  class LoginUserService
    include Deps[add_identity: 'commands.add_identity']

    def call(auth:)
      identity = Identity.find_by(uid: auth[:uid], provider: auth[:provider])
      return { result: identity.user } if identity.present?

      email = auth[:email]
      return { errors: ['Email is required'] } if email.nil?

      user = User.find_or_create_by!(email: email)
      # commento: identities.uid, identities.provider, identities.email, identities.login
      add_identity.call(auth.merge(user: user))

      { result: user }
    end
  end
end
