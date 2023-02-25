# frozen_string_literal: true

module Kudos
  module Achievementable
    extend ActiveSupport::Concern

    included do
      has_many :kudos_users_achievements,
               class_name: 'Kudos::Users::Achievement',
               dependent: :destroy

      has_many :kudos_achievements, through: :kudos_users_achievements
    end

    def award(achievement:)
      object = kudos_users_achievements.find_or_initialize_by(kudos_achievement_id: achievement.id)
      return if object.rank.to_i > achievement.rank.to_i

      object.update!(
        {
          rank: achievement.rank,
          points: object.points.to_i + achievement.points,
          title: achievement.title,
          description: achievement.description
        }.compact
      )
    end

    def awarded?(achievement:)
      kudos_users_achievements.find_by({ kudos_achievement_id: achievement.id, rank: achievement.rank }.compact)
    end
  end
end
