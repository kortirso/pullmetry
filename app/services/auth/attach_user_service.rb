# frozen_string_literal: true

module Auth
  class AttachUserService
    def call(user:, auth:)
      identity = Identity.find_by(uid: auth[:uid], provider: auth[:provider])
      return if identity.present?

      email = auth[:email]
      return if email.nil?

      # commento: identities.uid, identities.provide, identities.email, identities.login
      Identities::CreateService.call(user: user, params: auth)
    end
  end
end
