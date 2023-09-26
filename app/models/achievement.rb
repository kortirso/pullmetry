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
    count = user.insights.actual.of_type('Company').sum(:comments_count)

    achievements.each do |achievement|
      if !user.awarded?(achievement: achievement) && count >= DEFAULT_CREATE_RANKS[achievement.rank]
        user.award(achievement: achievement)
      end
    end
  end

  award_for :review_create do |achievements, user|
    count = user.insights.actual.of_type('Company').sum(:reviews_count)

    achievements.each do |achievement|
      if !user.awarded?(achievement: achievement) && count >= DEFAULT_CREATE_RANKS[achievement.rank]
        user.award(achievement: achievement)
      end
    end
  end

  award_for :pull_request_create do |achievements, user|
    count = user.insights.actual.of_type('Company').sum(:open_pull_requests_count)

    achievements.each do |achievement|
      if !user.awarded?(achievement: achievement) && count >= DEFAULT_CREATE_RANKS[achievement.rank]
        user.award(achievement: achievement)
      end
    end
  end
end
