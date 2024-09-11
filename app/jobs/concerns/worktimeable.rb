# frozen_string_literal: true

module Worktimeable
  extend ActiveSupport::Concern

  private

  def working_time?(company)
    return true unless company.with_work_time?
    return false if current_time.wday.in?(Insights::Time::BasisService::WEEKEND_DAYS_INDEXES)

    work_time = company.work_time
    return day_work_condition(work_time) if work_time.starts_at.to_time <= work_time.ends_at.to_time

    night_work_condition(work_time)
  end

  # 60 means - start 1 hour before start time
  def day_work_condition(work_time)
    return false if current_minutes < minutes_of_day(work_time.starts_at.to_time) - offset_minutes(work_time) - 60
    return false if current_minutes >= minutes_of_day(work_time.ends_at.to_time) - offset_minutes(work_time)

    true
  end

  def night_work_condition(work_time)
    return true if current_minutes >= minutes_of_day(work_time.starts_at.to_time) - offset_minutes(work_time) - 60
    return true if current_minutes < minutes_of_day(work_time.ends_at.to_time) - offset_minutes(work_time)

    false
  end

  def offset_minutes(work_time)
    (work_time.timezone || Insights::Time::BasisService::DEFAULT_WORK_TIME_ZONE).to_i *
      Insights::Time::BasisService::MINUTES_IN_HOUR
  end

  def current_minutes
    @current_minutes ||= minutes_of_day(current_time)
  end

  def minutes_of_day(time)
    (time.hour * Insights::Time::BasisService::MINUTES_IN_HOUR) + time.min
  end

  def current_time
    @current_time ||= DateTime.now
  end
end
