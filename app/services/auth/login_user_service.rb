# frozen_string_literal: true

module Auth
  class LoginUserService
    include Deps[create_form: 'forms.identities.create']

    def call(auth:)
      identity = Identity.find_by(uid: auth[:uid], provider: auth[:provider])
      return { result: identity.user } if identity.present?

      email = auth[:email]
      return { errors: ['Email is required'] } if email.nil?

      user = User.find_or_create_by!(email: email)
      # commento: identities.uid, identities.provider, identities.email, identities.login
      create_form.call(user: user, params: auth)

      { result: user }
    end
  end
end
