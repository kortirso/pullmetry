# frozen_string_literal: true

module Users
  class RefreshAchievementsJob < ApplicationJob
    queue_as :default

    def perform
      Pullmetry::Container['services.persisters.users.refresh_achievements'].call
    end
  end
end
