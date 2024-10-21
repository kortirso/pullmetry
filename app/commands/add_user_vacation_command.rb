# frozen_string_literal: true

class AddUserVacationCommand < BaseCommand
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
  end

  def do_persist(input)
    error = validate_time(input)
    return { errors: [error] } if error.present?

    vacation = User::Vacation.create!(input)

    { result: vacation }
  end

  def transform_date(value)
    suppress(Date::Error) { DateTime.parse(value) }
  end

  def validate_time(input)
    return 'Start time is invalid' if input[:start_time].nil?
    return 'End time is invalid' if input[:end_time].nil?

    'Start time must be before end time' if input[:start_time] > input[:end_time]
  end
end
