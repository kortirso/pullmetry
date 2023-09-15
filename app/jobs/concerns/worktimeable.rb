# frozen_string_literal: true

module Worktimeable
  extend ActiveSupport::Concern

  private

  def working_time?(company)
    return true unless company.with_work_time?
    return false if current_time.wday.in?(Insights::AverageTime::BasisService::WEEKEND_DAYS_INDEXES)

    configuration = company.configuration
    value_minutes = minutes_of_day(current_time)

    return false if value_minutes <= minutes_of_day(configuration.work_start_time)
    return false if value_minutes >= minutes_of_day(configuration.work_end_time)

    true
  end

  def minutes_of_day(time)
    (time.hour * Insights::AverageTime::BasisService::MINUTES_IN_HOUR) + time.min
  end

  def current_time
    @current_time ||= DateTime.now
  end
end
