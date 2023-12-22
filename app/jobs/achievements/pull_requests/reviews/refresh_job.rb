# frozen_string_literal: true

module Achievements
  module PullRequests
    module Reviews
      class RefreshJob < ApplicationJob
        queue_as :default

        def perform(id:)
          user = User.find_by(id: id)
          return unless user

          Achievement.award(:review_create, user)
        end
      end
    end
  end
end
