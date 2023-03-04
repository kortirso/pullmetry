# frozen_string_literal: true

module Vacations
  class CreateService
    prepend ApplicationService

    def call(user:, params:)
      @params = params
      return if convert_time && validate_time && failure?

      user.vacations.create!(@params.slice(:start_time, :end_time))
    end

    private

    def convert_time
      @params[:start_time] = DateTime.new(time(:start, 1), time(:start, 2), time(:start, 3))
      @params[:end_time] = DateTime.new(time(:end, 1), time(:end, 2), time(:end, 3))
    end

    def time(name, index)
      @params["#{name}_time(#{index}i)"].to_i
    end

    def validate_time
      return if @params[:start_time] < @params[:end_time]

      fail!('Start time must be before end time')
    end
  end
end
