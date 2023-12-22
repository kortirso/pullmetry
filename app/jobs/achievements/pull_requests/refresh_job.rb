# frozen_string_literal: true

module Achievements
  module PullRequests
    class RefreshJob < ApplicationJob
      queue_as :default

      def perform(id:)
        user = User.find_by(id: id)
        return unless user

        Achievement.award(:pull_request_create, user)
      end
    end
  end
end
