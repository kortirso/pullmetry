# frozen_string_literal: true

class Achievement < Kudos::Achievement
  DEFAULT_CREATE_RANKS = {
    1 => 1,
    2 => 10,
    3 => 25,
    4 => 50,
    5 => 100
  }.freeze

  award_for :comment_create do |achievements, user|
    user_comments_count = user.insights.sum(:comments_count)

    achievements.each do |achievement|
      if !user.awarded?(achievement: achievement) && user_comments_count >= DEFAULT_CREATE_RANKS[achievement.rank]
        user.award(achievement: achievement)
      end
    end
  end

  award_for :review_create do |achievements, user|
    user_reviews_count = user.insights.sum(:reviews_count)

    achievements.each do |achievement|
      if !user.awarded?(achievement: achievement) && user_reviews_count >= DEFAULT_CREATE_RANKS[achievement.rank]
        user.award(achievement: achievement)
      end
    end
  end

  award_for :pull_request_create do |achievements, user|
    user_pull_requests_count = user.insights.sum(:open_pull_requests_count)

    achievements.each do |achievement|
      if !user.awarded?(achievement: achievement) && user_pull_requests_count >= DEFAULT_CREATE_RANKS[achievement.rank]
        user.award(achievement: achievement)
      end
    end
  end
end
