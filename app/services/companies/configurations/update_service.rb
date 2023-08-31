# frozen_string_literal: true

module Companies
  module Configurations
    class UpdateService
      prepend ApplicationService

      def call(company:, params:, use_work_time:)
        @params = params

        convert_working_time(use_work_time)
        return if use_work_time && validate_work_time && failure?

        sliced_params = sliced_params(company)
        ActiveRecord::Base.transaction do
          clear_insights_ratios(company) if need_clear_insights_ratios?(company, sliced_params[:insight_ratio_type])
          company.configuration.assign_attributes(sliced_params)
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

      def need_clear_insights_ratios?(company, insight_ratio_type)
        company.premium? && insight_ratio_type != company.configuration.insight_ratio_type
      end

      def clear_insights_ratios(company)
        Insight.where(insightable: company)
          .or(Insight.where(insightable: company.repositories))
          .update_all(
            comments_count_ratio: nil,
            reviews_count_ratio: nil,
            required_reviews_count_ratio: nil,
            open_pull_requests_count_ratio: nil,
            average_review_seconds_ratio: nil,
            average_merge_seconds_ratio: nil,
            average_open_pr_comments_ratio: nil,
            review_involving_ratio: nil
          )
      end

      def sliced_params(company)
        params_list = %i[ignore_users_work_time work_time_zone work_start_time work_end_time average_type]
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
