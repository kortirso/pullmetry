# frozen_string_literal: true

module Frontend
  module Companies
    class ConfigurationsController < Frontend::BaseController
      include Deps[change_company_configuration: 'commands.change_company_configuration']

      before_action :find_company

      def update
        authorize! @company
        # commento: companies.configuration
        case change_company_configuration.call(configuration_params.merge(company: @company))
        in { errors: errors } then render json: { errors: errors }, status: :ok
        else render json: {}, status: :ok
        end
      end

      private

      def find_company
        @company = Company.find_by!(uuid: params[:company_id])
      end

      def configuration_params
        params
          .require(:configuration)
          .permit(
            :private,
            :ignore_users_work_time,
            :main_attribute,
            :average_type,
            :insight_ratio,
            :insight_ratio_type,
            :fetch_period,
            insight_fields: []
          ).to_h
      end
    end
  end
end
