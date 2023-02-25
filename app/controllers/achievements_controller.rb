# frozen_string_literal: true

class AchievementsController < ApplicationController
  before_action :find_achievements

  def show; end

  private

  def find_achievements
    @achievements = current_user.kudos_users_achievements.order(updated_at: :desc)
  end
end
