# frozen_string_literal: true

module Persisters
  module Users
    class RefreshAchievementsService
      def call
        User.find_each do |user|
          publish_event(event: PullRequests::Comments::CreatedEvent, data: { user_uuid: user.uuid })
          publish_event(event: PullRequests::Reviews::CreatedEvent, data: { user_uuid: user.uuid })
          publish_event(event: PullRequests::CreatedEvent, data: { user_uuid: user.uuid })
        end
      end

      private

      def publish_event(event:, data: {})
        event_store.publish(
          event.new(data: data)
        )
      end

      def event_store
        @event_store ||= Rails.configuration.event_store
      end
    end
  end
end
