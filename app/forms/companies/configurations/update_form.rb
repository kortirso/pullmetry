# frozen_string_literal: true

module Companies
  module Configurations
    class UpdateForm
      def call(company:, params:, use_work_time:)
        params = convert_working_time(params, use_work_time)
        error = validate_work_time(params, use_work_time)
        return { errors: [error] } if error

        error = validate_fetch_period(params, company)
        return { errors: [error] } if error

        ActiveRecord::Base.transaction do
          company.configuration.assign_attributes(sliced_params(params, company))
          company.save!
        end

        { result: company.reload }
      end

      private

      def convert_working_time(params, use_work_time)
        params[:work_start_time] = use_work_time ? generate_date(params, :start) : nil
        params[:work_end_time] = use_work_time ? generate_date(params, :end) : nil
        params
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

      def validate_fetch_period(params, company)
        fetch_period = params[:fetch_period]
        return if fetch_period.blank?
        return if fetch_period.to_i <= Insight::FETCH_DAYS_PERIOD
        return if company.premium? && fetch_period.to_i <= Insight::MAXIMUM_FETCH_DAYS_PERIOD

        'Invalid value of days for fetch period'
      end

      def sliced_params(params, company)
        params_list = %i[
          ignore_users_work_time work_time_zone work_start_time work_end_time private average_type fetch_period
          long_time_review_hours
        ]
        # premium account has more available attributes for update
        if company.premium?
          params_list.push(:insight_fields, :insight_ratio, :insight_ratio_type, :main_attribute)
        end
        params.slice(*params_list)
      end
    end
  end
end
