# frozen_string_literal: true

module Users
  class DestroyService
    def call(user:)
      ActiveRecord::Base.transaction do
        user.users_sessions.destroy_all
        user.companies.destroy_all
        user.identities.destroy_all
        user.vacations.destroy_all
        user.kudos_users_achievements.destroy_all
        user.notifications.destroy_all
      end
    end
  end
end
