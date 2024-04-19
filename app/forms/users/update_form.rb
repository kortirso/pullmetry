# frozen_string_literal: true

module Users
  class UpdateForm
    def call(user:, params:, use_work_time:)
      params = convert_working_time(params, use_work_time)
      error = validate_work_time(params, use_work_time)
      return { errors: [error] } if error

      user.update!(params)

      { result: user.reload }
    end

    private

    def convert_working_time(params, use_work_time)
      params[:work_start_time] = use_work_time ? generate_date(params, :start) : nil
      params[:work_end_time] = use_work_time ? generate_date(params, :end) : nil

      params.delete_if { |k, _v| k.include?('_time(') }
    end

    def generate_date(params, position)
      DateTime.new(2023, 1, 1, time(params, position, 4), time(params, position, 5))
    end

    def time(params, name, index)
      params["work_#{name}_time(#{index}i)"].to_i
    end

    def validate_work_time(params, use_work_time)
      return unless use_work_time
      return if params[:work_start_time] != params[:work_end_time]

      'Start and end time must be different'
    end
  end
end
