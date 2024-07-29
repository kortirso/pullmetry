# frozen_string_literal: true

module Auth
  class AttachIdentityService
    include Deps[add_identity: 'commands.add_identity']

    def call(user:, auth:)
      identity = Identity.find_by(uid: auth[:uid], provider: auth[:provider])
      return { result: identity } if identity.present?

      auth[:email] = user.email if auth[:email].nil?
      # commento: identities.uid, identities.provide, identities.email, identities.login
      { result: add_identity.call(auth.merge(user: user))[:result] }
    end
  end
end
