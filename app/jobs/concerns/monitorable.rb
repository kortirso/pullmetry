# frozen_string_literal: true

module Monitorable
  extend ActiveSupport::Concern

  included do
    after_perform do |job|
      AdminDelivery.with(job: job).job_execution_report.deliver_later
    end
  end
end
