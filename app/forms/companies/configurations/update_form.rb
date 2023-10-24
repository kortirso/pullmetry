# frozen_string_literal: true

module Companies
  module Configurations
    class UpdateForm
      prepend ApplicationService

      ALLOWED_EXCLUDE_RULES = %i[title description branch_name destination_branch_name].freeze

      def call(company:, params:, use_work_time:)
        @params = params

        convert_working_time(use_work_time)
        return if use_work_time && validate_work_time && failure?

        transform_pull_request_exclude_rules
        ActiveRecord::Base.transaction do
          # commento: companies.configuration
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
        return if @params[:work_start_time] != @params[:work_end_time]

        fail!('Start and end time must be different')
      end

      def transform_pull_request_exclude_rules
        return if @params[:pull_request_exclude_rules].blank?

        @params[:pull_request_exclude_rules] =
          JSON.parse(@params[:pull_request_exclude_rules])
            .symbolize_keys
            .slice(*ALLOWED_EXCLUDE_RULES)
            .transform_values(&:compact_blank)
            .to_json
      end

      def sliced_params(company)
        params_list = %i[
          ignore_users_work_time work_time_zone work_start_time work_end_time
          private average_type pull_request_exclude_rules
        ]
        # premium account has more available attributes for update
        if company.premium?
          params_list.push(
            :insight_fields, :insight_ratio, :insight_ratio_type, :insights_webhook_url,
            :insights_discord_webhook_url, :main_attribute
          )
        end
        @params.slice(*params_list)
      end
    end
  end
end
