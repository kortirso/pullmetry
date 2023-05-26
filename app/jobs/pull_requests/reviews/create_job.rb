# frozen_string_literal: true

module PullRequests
  module Reviews
    class CreateJob < ApplicationJob
      prepend RailsEventStore::AsyncHandler

      queue_as :default

      def perform(event)
        user = User.find_by(uuid: event.data.fetch(:user_uuid))
        return unless user

        Achievement.award(:review_create, user)
      end
    end
  end
end
