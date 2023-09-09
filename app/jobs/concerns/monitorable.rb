# frozen_string_literal: true

module Monitorable
  extend ActiveSupport::Concern

  included do
    after_perform do |job|
      Export::Slack::Reports::Jobs::SendService.call(job: job)
    end
  end
end
