# frozen_string_literal: true

module Vacations
  class CreateForm
    def call(user:, params:)
      converted_time = convert_time(params)
      error = validate_time(converted_time)
      return { errors: [error] } if error.present?

      { result: user.vacations.create!(converted_time) }
    end

    private

    def convert_time(params)
      {
        start_time: DateTime.new(time(params, :start, 1), time(params, :start, 2), time(params, :start, 3)),
        end_time: DateTime.new(time(params, :end, 1), time(params, :end, 2), time(params, :end, 3))
      }
    end

    def time(params, name, index)
      params["#{name}_time(#{index}i)"].to_i
    end

    def validate_time(params)
      return if params[:start_time] < params[:end_time]

      'Start time must be before end time'
    end
  end
end
