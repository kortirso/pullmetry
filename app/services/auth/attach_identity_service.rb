# frozen_string_literal: true

module Auth
  class AttachIdentityService
    include Deps[create_form: 'forms.identities.create']

    def call(user:, auth:)
      identity = Identity.find_by(uid: auth[:uid], provider: auth[:provider])
      return { result: identity } if identity.present?

      auth[:email] = user.email if auth[:email].nil?
      # commento: identities.uid, identities.provide, identities.email, identities.login
      { result: create_form.call(user: user, params: auth)[:result] }
    end
  end
end
