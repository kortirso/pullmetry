# frozen_string_literal: true

module Api
  module Frontend
    module Companies
      class ConfigurationsController < Api::FrontendController
        include Deps[
          change_company_configuration: 'commands.change_company_configuration',
          to_bool: 'to_bool'
        ]

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
              :private
            ).to_h
        end
      end
    end
  end
end
