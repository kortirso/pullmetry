# frozen_string_literal: true

class RemoveUserCommand < BaseCommand
  use_contract do
    params do
      required(:user).filled(type?: User)
    end
  end

  private

  # rubocop: disable Metrics/AbcSize
  def do_persist(input)
    user = input[:user]
    ActiveRecord::Base.transaction do
      user.invites.destroy_all
      user.receive_invites.update_all(receiver_id: nil)
      user.users_sessions.destroy_all
      user.companies.destroy_all
      user.identities.destroy_all
      user.vacations.destroy_all
      user.kudos_users_achievements.destroy_all
      user.notifications.destroy_all
      user.feedbacks.destroy_all
      user.api_access_tokens.destroy_all
      user.companies_users.destroy_all
    end
  end
  # rubocop: enable Metrics/AbcSize
end
