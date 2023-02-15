# frozen_string_literal: true

module Export
  class SendInsightsNotificationJob < ApplicationJob
    queue_as :default

    def perform(send_service: Export::Slack::Insights::SendService.new)
      Company
        .where(user_id: Subscription.active.select(:user_id))
        .find_each do |company|
          send_service.call(insightable: company)
        end
    end
  end
end
