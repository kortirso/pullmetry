# frozen_string_literal: true

module Companies
  module Configurations
    class UpdateService
      prepend ApplicationService

      def call(company:, params:, use_work_time:)
        @params = params

        convert_working_time(use_work_time)
        return if use_work_time && validate_work_time && failure?

        company.configuration.assign_attributes(@params.slice(:work_start_time, :work_end_time))
        company.save!
      end

      private

      def convert_working_time(use_work_time)
        @params[:work_start_time] = use_work_time ? DateTime.new(2023, 1, 1, time(:start, 4), time(:start, 5)) : nil
        @params[:work_end_time] = use_work_time ? DateTime.new(2023, 1, 1, time(:end, 4), time(:end, 5)) : nil
      end

      def time(name, index)
        @params["work_#{name}_time(#{index}i)"].to_i
      end

      def validate_work_time
        return if @params[:work_start_time] < @params[:work_end_time]

        fail!('Start time must be before end time')
      end
    end
  end
end