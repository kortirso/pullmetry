# frozen_string_literal: true

class ChangeUserCommand < BaseCommand
  use_contract do
    params do
      required(:user).filled(type?: User)
      optional(:start_time).maybe(:string)
      optional(:end_time).maybe(:string)
      optional(:time_zone).maybe(:string)
    end
  end

  private

  def validate_content(input)
    validate_times(input)
  end

  def do_persist(input)
    input[:user].update!(input.except(:user))

    { result: input[:user].reload }
  end

  def validate_times(input)
    start_time_error = validate_time(input[:start_time])
    return "Start time's #{start_time_error}" if start_time_error

    end_time_error = validate_time(input[:end_time])
    return "End time's #{end_time_error}" if end_time_error
    return "Time zone's value is invalid" unless input[:time_zone].to_i.between?(-12, 13)

    'Start and end time must be different' if input[:start_time] == input[:end_time]
  end

  def validate_time(value)
    return if value.nil?

    hours, minutes = value.split(':')
    return 'value has invalid format' if hours.nil? || minutes.nil?
    return 'hours value is invalid' unless hours.to_i.between?(0, 23)

    'minutes value is invalid' unless minutes.to_i.between?(0, 59)
  end
end
