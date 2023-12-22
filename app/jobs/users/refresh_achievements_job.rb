# frozen_string_literal: true

module Users
  class RefreshAchievementsJob < ApplicationJob
    queue_as :default

    def perform
      User.pluck(:id).each do |user_id|
        Achievements::PullRequests::Comments::RefreshJob.perform_later(id: user_id)
        Achievements::PullRequests::Reviews::RefreshJob.perform_later(id: user_id)
        Achievements::PullRequests::RefreshJob.perform_later(id: user_id)
      end
    end
  end
end
