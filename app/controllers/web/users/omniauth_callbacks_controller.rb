# frozen_string_literal: true

module Web
  module Users
    class OmniauthCallbacksController < Authkeeper::OmniauthCallbacksController
      include Deps[
        add_identity: 'commands.add_identity',
        monitoring: 'monitoring.client'
      ]

      def create
        user = auth_login(auth, current_user)
        if user
          sign_in(user) if current_user.nil?
          accept_invite(user)
          redirect_to((current_user.nil? ? companies_path : profile_path), notice: 'Authentication succeed')
        else
          monitoring_failed_auth(auth)
          redirect_to root_path, alert: 'Authentication failed'
        end
      end

      private

      # rubocop: disable Metrics/AbcSize
      def auth_login(auth, user=nil)
        identity = Identity.find_by(uid: auth[:uid], provider: auth[:provider])
        return identity.user if identity.present?

        auth[:email] = user&.email if auth[:email].nil?
        return if auth[:email].nil?

        ActiveRecord::Base.transaction do
          user = User.find_or_create_by!(email: auth[:email]) if user.nil?
          # commento: identities.uid, identities.provider, identities.email, identities.login
          add_identity.call(auth.merge(user: user))
        end

        user
      end
      # rubocop: enable Metrics/AbcSize

      def monitoring_failed_auth(auth)
        monitoring.notify(
          exception: 'Failed authentication',
          metadata: { provider: params[:provider], payload: auth },
          severity: :info
        )
      end
    end
  end
end
