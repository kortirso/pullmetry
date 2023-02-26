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
    user_comments_count = user.insights.sum(:comments_count)

    achievements.each do |achievement|
      if !user.awarded?(achievement: achievement) && user_comments_count >= COMMENT_CREATE_RANKS[achievement.rank]
        user.award(achievement: achievement)
      end
    end
  end
end
