# frozen_string_literal: true

module Companies
  class ConfigurationsController < ApplicationController
    include Boolable

    before_action :find_company

    def edit
      authorize! @company, to: :update?

      find_insight_ratio_type_values
      find_average_type_values
      find_main_attribute_values
    end

    def update
      authorize! @company, to: :update?
      form = Companies::Configurations::UpdateForm.call(
        company: @company,
        params: configuration_params,
        use_work_time: to_bool(params[:jsonb_columns_configuration][:use_work_time])
      )
      if form.success?
        redirect_to companies_path
      else
        redirect_to edit_company_configuration_path(@company.uuid), alert: form.errors
      end
    end

    private

    def find_company
      @company = current_user.companies.find_by!(uuid: params[:company_id])
    end

    def find_insight_ratio_type_values
      @insight_ratio_type_values = @company.configuration.insight_ratio_type_values.map { |key, _v| transform_key(key) }
    end

    def find_average_type_values
      @average_type_values = @company.configuration.average_type_values.map { |key, _v| transform_key(key) }
    end

    def find_main_attribute_values
      @main_attribute_values = @company.configuration.main_attribute_values.map { |key, _v| transform_key(key) }
    end

    def transform_key(key)
      [key.to_s.capitalize.split('_').join(' '), key]
    end

    def configuration_params
      params
        .require(:jsonb_columns_configuration)
        .permit(
          :insight_ratio,
          :insight_ratio_type,
          :insights_webhook_url,
          :insights_discord_webhook_url,
          :ignore_users_work_time,
          :work_time_zone,
          :work_start_time,
          :work_end_time,
          :average_type,
          :main_attribute,
          :pull_request_exclude_rules,
          insight_fields: {}
        )
    end
  end
end
