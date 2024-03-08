# frozen_string_literal: true

module Companies
  module Configurations
    class UpdateForm
      prepend ApplicationService

      def call(company:, params:, use_work_time:)
        @params = params

        convert_working_time(use_work_time)
        return if use_work_time && validate_work_time && failure?
        return if validate_fetch_period(company) && failure?

        ActiveRecord::Base.transaction do
          company.configuration.assign_attributes(sliced_params(company))
          company.save!
        end
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
        return true if @params[:work_start_time] != @params[:work_end_time]

        fail!('Start and end time must be different')
      end

      def validate_fetch_period(company)
        fetch_period = @params[:fetch_period]
        return if fetch_period.blank?
        return if fetch_period.to_i <= Insight::FETCH_DAYS_PERIOD
        return if company.premium? && fetch_period.to_i <= Insight::MAXIMUM_FETCH_DAYS_PERIOD

        fail!('Invalid value of days for fetch period')
      end

      def sliced_params(company)
        params_list = %i[
          ignore_users_work_time work_time_zone work_start_time work_end_time private average_type fetch_period
          long_time_review_hours
        ]
        # premium account has more available attributes for update
        if company.premium?
          params_list.push(:insight_fields, :insight_ratio, :insight_ratio_type, :main_attribute)
        end
        @params.slice(*params_list)
      end
    end
  end
end
