# frozen_string_literal: true

module Deliveries
  module Companies
    class RepositoryInsightsReportJob < ApplicationJob
      include Worktimeable

      queue_as :default

      def perform(delivery_service: CompanyDelivery)
        Notification
          .repository_insights_data
          .preload(:notifyable)
          .find_each do |notification|
            next unless working_time?(notification.notifyable)

            delivery_service
              .with(notification: notification)
              .repository_insights_report
              .deliver_later
          end
      end
    end
  end
end
