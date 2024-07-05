# frozen_string_literal: true

module Deliveries
  module Companies
    class InsightsReportJob < ApplicationJob
      include Worktimeable

      queue_as :default

      def perform(delivery_service: CompanyDelivery)
        Company
          .joins(:notifications)
          .find_each do |company|
            next unless working_time?(company)

            delivery_service
              .with(company: company)
              .insights_report
              .deliver_later
          end
      end
    end
  end
end
