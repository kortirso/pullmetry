# frozen_string_literal: true

module Export
  class SendInsightsNotificationJob < ApplicationJob
    include Worktimeable

    queue_as :default

    def perform(delivery_service: InsightDelivery)
      Company
        .where.associated(:insights)
        .find_each do |company|
          next unless working_time?(company)

          delivery_service.with(insightable: company).report.deliver_later
        end
    end
  end
end
