# frozen_string_literal: true

module Vacations
  class CreateForm
    def call(user:, params:)
      converted_time = convert_time(params)
      error = validate_time(converted_time)
      return { errors: [error] } if error.present?

      { result: user.vacations.create!(converted_time) }
    rescue Date::Error => _e
      { errors: ['Invalid date format'] }
    end

    private

    def convert_time(params)
      {
        start_time: DateTime.parse(params[:start_time]),
        end_time: DateTime.parse(params[:end_time])
      }
    end

    def validate_time(params)
      return if params[:start_time] < params[:end_time]

      'Start time must be before end time'
    end
  end
end
