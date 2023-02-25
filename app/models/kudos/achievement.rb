# frozen_string_literal: true

module Kudos
  class Achievement < Kudos::ApplicationRecord
    self.table_name = :kudos_achievements

    include Kudos
    include Uuidable

    belongs_to :kudos_achievement_group, class_name: 'Kudos::AchievementGroup'

    has_many :kudos_users_achievements,
             class_name: 'Kudos::Users::Achievement',
             foreign_key: :kudos_achievement_id,
             dependent: :destroy

    has_many :users, through: :kudos_users_achievements
  end
end
