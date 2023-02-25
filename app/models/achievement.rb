# frozen_string_literal: true

class Achievement < Kudos::Achievement
  COMMENT_CREATE_RANKS = {
    1 => 1,
    2 => 10,
    3 => 25,
    4 => 50,
    5 => 100
  }.freeze

  award_for :comment_create do |achievements, user|
    achievements.each do |achievement|
      if !user.awarded?(achievement: achievement) && user_comments_count(user) >= COMMENT_CREATE_RANKS[achievement.rank]
        user.award(achievement: achievement)
      end
    end
  end

  private

  def user_comments_count(user)
    @user_comments_count ||= user.insights.sum(:comments_count)
  end
end
