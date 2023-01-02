# frozen_string_literal: true

module Auth
  class LoginUserService
    prepend ApplicationService

    def call(auth:)
      identity = Identity.find_for_oauth(auth)
      return @result = identity.user if identity.present?

      email = auth.info[:email]
      return if email.nil?

      @result = User.find_or_create_by!(email: email)
      Identities::CreateService.call(
        user: @result,
        params: { uid: auth.uid, provider: auth.provider, email: email, login: auth.info['nickname'] }
      )
    end
  end
end
