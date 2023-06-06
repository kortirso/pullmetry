# frozen_string_literal: true

module Companies
  class ConfigurationsController < ApplicationController
    before_action :find_company

    def edit
      authorize! @company, to: :update?
      find_average_type_values
      find_main_attribute_values
    end

    def update
      authorize! @company, to: :update?
      service_call = Companies::Configurations::UpdateService.call(
        company: @company,
        params: configuration_params,
        use_work_time: ActiveModel::Type::Boolean.new.cast(params[:jsonb_columns_configuration][:use_work_time])
      )
      if service_call.success?
        redirect_to companies_path, notice: "Configuration for company #{@company.title} is updated"
      else
        redirect_to edit_company_configuration_path(@company.uuid), alert: service_call.errors
      end
    end

    private

    def find_company
      @company = current_user.companies.find_by!(uuid: params[:company_id])
    end

    def find_average_type_values
      @average_type_values = @company.configuration.average_type_values.map do |key, _v|
        [key.to_s.capitalize.split('_').join(' '), key]
      end
    end

    def find_main_attribute_values
      @main_attribute_values = @company.configuration.main_attribute_values.map do |key, _v|
        [key.to_s.capitalize.split('_').join(' '), key]
      end
    end

    def configuration_params
      params
        .require(:jsonb_columns_configuration)
        .permit(
          :insight_ratio,
          :insights_webhook_url,
          :insights_discord_webhook_url,
          :work_start_time,
          :work_end_time,
          :average_type,
          :main_attribute,
          insight_fields: {}
        )
    end
  end
end
