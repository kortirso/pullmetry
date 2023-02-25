# frozen_string_literal: true

module Users
  class RefreshAchievementsService
    prepend ApplicationService
    include Publishable

    def call
      User.find_each do |user|
        publish_event(event: PullRequests::Comments::CreatedEvent, data: { user_uuid: user.uuid })
      end
    end
  end
end
