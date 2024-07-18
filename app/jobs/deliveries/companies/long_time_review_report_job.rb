# frozen_string_literal: true

module Deliveries
  module Companies
    class LongTimeReviewReportJob < ApplicationJob
      include Worktimeable

      queue_as :default

      def perform(delivery_service: CompanyDelivery)
        Notification
          .long_time_review_data
          .preload(:notifyable)
          .find_each do |notification|
            next unless working_time?(notification.notifyable)

            delivery_service
              .with(notification: notification)
              .long_time_review_report
              .deliver_later
          end
      end
    end
  end
end
