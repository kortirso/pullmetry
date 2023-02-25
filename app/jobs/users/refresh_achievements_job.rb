# frozen_string_literal: true

module Users
  class RefreshAchievementsJob < ApplicationJob
    queue_as :default

    def perform
      Users::RefreshAchievementsService.call
    end
  end
end
