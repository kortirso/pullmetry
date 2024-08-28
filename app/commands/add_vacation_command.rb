# frozen_string_literal: true

class AddVacationCommand < BaseCommand
  use_contract do
    params do
      required(:user).filled(type?: User)
      required(:start_time).filled(:string)
      required(:end_time).filled(:string)
    end
  end

  private

  def do_prepare(input)
    input[:start_time] = transform_date(input[:start_time])
    input[:end_time] = transform_date(input[:end_time])
    input
  end

  def do_persist(input)
    error = validate_time(input)
    return { errors: [error] } if error.present?

    vacation = Vacation.create!(input)

    { result: vacation }
  end

  def transform_date(value)
    DateTime.parse(value)
  rescue Date::Error => _e
  end

  def validate_time(input)
    return 'Start time is invalid' if input[:start_time].nil?
    return 'End time is invalid' if input[:end_time].nil?

    'Start time must be before end time' if input[:start_time] > input[:end_time]
  end
end