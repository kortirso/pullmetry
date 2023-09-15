# frozen_string_literal: true

module Auth
  class LoginUserOperation
    prepend ApplicationService

    def call(auth:)
      identity = Identity.find_by(uid: auth[:uid], provider: auth[:provider])
      return @result = identity.user if identity.present?

      email = auth[:email]
      return if email.nil?

      @result = User.find_or_create_by!(email: email)
      # commento: identities.uid, identities.provider, identities.email, identities.login
      Identities::CreateForm.call(user: @result, params: auth)
    end
  end
end
