# frozen_string_literal: true

class ChangeWorkTimeCommand < BaseCommand
  use_contract do
    params do
      required(:worktimeable).filled(type_included_in?: [Company, User])
      optional(:starts_at).maybe(:string)
      optional(:ends_at).maybe(:string)
      optional(:timezone).maybe(:string)
    end
  end

  private

  def validate_content(input)
    validate_times(input)
  end

  def do_persist(input)
    input[:worktimeable].build_work_time if input[:worktimeable].work_time.nil?
    input[:worktimeable].work_time.update(input.except(:worktimeable))

    { result: input[:worktimeable].reload }
  end

  def validate_times(input)
    start_time_error = validate_time(input[:starts_at])
    return "Start time's #{start_time_error}" if start_time_error

    end_time_error = validate_time(input[:ends_at])
    return "End time's #{end_time_error}" if end_time_error
    return "Time zone's value is invalid" unless input[:timezone].to_i.between?(-12, 13)
    return 'Start and end time must be different' if input[:starts_at] == input[:ends_at]

    'Start time should be before end time' if input[:starts_at] >= input[:ends_at]
  end

  def validate_time(value)
    return if value.nil?

    hours, minutes = value.split(':')
    return 'value has invalid format' if hours.nil? || minutes.nil?
    return 'hours value is invalid' unless hours.to_i.between?(0, 23)

    'minutes value is invalid' unless minutes.to_i.between?(0, 59)
  end
end
