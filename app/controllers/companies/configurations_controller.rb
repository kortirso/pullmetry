# frozen_string_literal: true

module Companies
  class ConfigurationsController < ApplicationController
    before_action :find_company

    def edit
      authorize! @company, to: :update?
    end

    def update
      authorize! @company, to: :update?
      service_call = Companies::Configurations::UpdateService.call(
        company: @company,
        params: configuration_params,
        use_work_time: params[:jsonb_columns_configuration][:use_work_time] == '1'
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

    def configuration_params
      params.require(:jsonb_columns_configuration).permit(:work_start_time, :work_end_time, insight_fields: {})
    end
  end
end
