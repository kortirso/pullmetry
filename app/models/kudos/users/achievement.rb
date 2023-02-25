# frozen_string_literal: true

module Kudos
  module Users
    class Achievement < ApplicationRecord
      self.table_name = :kudos_users_achievements

      belongs_to :user, class_name: '::User'
      belongs_to :kudos_achievement, class_name: 'Kudos::Achievement'

      scope :unread, -> { where(notified: false) }
    end
  end
end
