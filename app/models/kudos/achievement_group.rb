# frozen_string_literal: true

module Kudos
  class AchievementGroup < ApplicationRecord
    self.table_name = :kudos_achievement_groups

    include Uuidable

    belongs_to :parent,
               class_name: 'Kudos::AchievementGroup',
               foreign_key: :parent_id,
               inverse_of: :children,
               optional: true

    has_many :children,
             class_name: 'Kudos::AchievementGroup',
             foreign_key: :parent_id,
             inverse_of: :parent,
             dependent: :nullify

    has_many :kudos_achievements,
             class_name: 'Kudos::Achievement',
             foreign_key: :kudos_achievement_group_id,
             dependent: :destroy
  end
end
