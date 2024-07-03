# frozen_string_literal: true

module Telegram
  module Admin
    class JobExecutionReportPayload
      def call(job_name:)
        "#{job_name} is run at #{DateTime.now}"
      end
    end
  end
end
