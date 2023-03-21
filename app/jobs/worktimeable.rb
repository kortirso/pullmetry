# frozen_string_literal: true

module Worktimeable
  extend ActiveSupport::Concern

  private

  def working_time?(company)
    return true unless company.with_work_time?

    current_time = DateTime.now
    current_time >= company.configuration.work_start_time && current_time <= company.configuration.work_end_time
  end
end
