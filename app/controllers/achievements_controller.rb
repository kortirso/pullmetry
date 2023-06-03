# frozen_string_literal: true

class AchievementsController < ApplicationController
  SUMMARY_ACHIEVEMENTS_RENDER_SIZE = 5

  before_action :find_achievements
  before_action :find_achievements_points
  before_action :find_unreceived_achievements

  def show; end

  private

  def find_achievements
    base_achievements
    filter_achievements
    group_achievements
    @achievements = @achievements.first(SUMMARY_ACHIEVEMENTS_RENDER_SIZE) if params[:group].blank?
  end

  def base_achievements
    @achievements = current_user.kudos_users_achievements.order(rank: :desc).eager_load(:kudos_achievement)
  end

  def filter_achievements
    return if params[:group].blank?

    @achievements = @achievements.where(kudos_achievement: { kudos_achievement_group_id: params[:group].to_i })
  end

  def group_achievements
    @achievements =
      @achievements
      .group_by { |users_achievement| users_achievement.kudos_achievement.award_name }
      .map { |_key, values| values.first }
  end

  def find_achievements_points
    @achievements_points = current_user.kudos_users_achievements.sum(:points)
  end

  def find_unreceived_achievements
    @unreceived_achievements =
      Kudos::Achievement
      .where.not(id: received_achievements_ids)
      .order(award_name: :asc, rank: :asc)

    @unreceived_achievements =
      if params[:group].present?
        @unreceived_achievements.where(kudos_achievement_group_id: params[:group])
      else
        @unreceived_achievements.first(SUMMARY_ACHIEVEMENTS_RENDER_SIZE - @achievements.size)
      end
  end

  def received_achievements_ids
    current_user.kudos_users_achievements.select(:kudos_achievement_id)
  end
end
