# frozen_string_literal: true

module Worktimeable
  extend ActiveSupport::Concern

  private

  def working_time?(company)
    return true unless company.with_work_time?
    return false if current_time.wday.in?(Insights::AverageTime::BasisService::WEEKEND_DAYS_INDEXES)

    configuration = company.configuration
    return day_work_condition(configuration) if configuration.work_start_time <= configuration.work_end_time

    night_work_condition(configuration)
  end

  # 60 means - start 1 hour before start time
  def day_work_condition(configuration)
    return false if current_minutes < minutes_of_day(configuration.work_start_time) - offset_minutes(configuration) - 60
    return false if current_minutes >= minutes_of_day(configuration.work_end_time) - offset_minutes(configuration)

    true
  end

  def night_work_condition(configuration)
    return true if current_minutes >= minutes_of_day(configuration.work_start_time) - offset_minutes(configuration) - 60
    return true if current_minutes < minutes_of_day(configuration.work_end_time) - offset_minutes(configuration)

    false
  end

  def offset_minutes(configuration)
    ActiveSupport::TimeZone[
      configuration.work_time_zone || Insights::AverageTime::BasisService::DEFAULT_WORK_TIME_ZONE
    ].utc_offset / Insights::AverageTime::BasisService::MINUTES_IN_HOUR
  end

  def current_minutes
    @current_minutes ||= minutes_of_day(current_time)
  end

  def minutes_of_day(time)
    (time.hour * Insights::AverageTime::BasisService::MINUTES_IN_HOUR) + time.min
  end

  def current_time
    @current_time ||= DateTime.now
  end
end
