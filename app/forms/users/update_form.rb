# frozen_string_literal: true

module Users
  class UpdateForm
    prepend ApplicationService

    def call(user:, params:, use_work_time:)
      @params = params

      convert_working_time(use_work_time)
      return if use_work_time && validate_work_time && failure?

      user.update!(@params)
    end

    private

    def convert_working_time(use_work_time)
      @params[:work_start_time] = use_work_time ? DateTime.new(2023, 1, 1, time(:start, 4), time(:start, 5)) : nil
      @params[:work_end_time] = use_work_time ? DateTime.new(2023, 1, 1, time(:end, 4), time(:end, 5)) : nil

      @params = @params.delete_if { |k, _v| k.include?('_time(') }
    end

    def time(name, index)
      @params["work_#{name}_time(#{index}i)"].to_i
    end

    def validate_work_time
      return if @params[:work_start_time] != @params[:work_end_time]

      fail!('Start and end time must be different')
    end
  end
end
