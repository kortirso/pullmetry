# frozen_string_literal: true

module Deliveries
  module Companies
    class NoNewPullsReportJob < ApplicationJob
      include Worktimeable

      queue_as :default

      def perform(delivery_service: CompanyDelivery)
        Notification
          .no_new_pulls_data
          .preload(:notifyable)
          .find_each do |notification|
            next unless working_time?(notification.notifyable)

            delivery_service
              .with(notification: notification)
              .no_new_pulls_report
              .deliver_later
          end
      end
    end
  end
end
