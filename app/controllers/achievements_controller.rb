# frozen_string_literal: true

class AchievementsController < ApplicationController
  before_action :find_achievements
  before_action :find_unreceived_achievements

  def show; end

  private

  def find_achievements
    @achievements =
      current_user
      .kudos_users_achievements
      .order(rank: :desc)
      .includes(:kudos_achievement)
      .group_by { |users_achievement| users_achievement.kudos_achievement.award_name }
      .map { |_key, values| values.first }
  end

  def find_unreceived_achievements
    @unreceived_achievements =
      Kudos::Achievement
      .where.not(id: current_user.kudos_users_achievements.select(:kudos_achievement_id))
      .order(award_name: :asc, rank: :asc)
  end
end
