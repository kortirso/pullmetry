# frozen_string_literal: true

module Api
  module Frontend
    class IgnoresController < Api::Frontend::BaseController
      include Deps[create_form: 'forms.ignores.create']

      before_action :find_company, only: %i[create]
      before_action :find_ignore, only: %i[destroy]

      def create
        # commento: ignores.entity_value
        case create_form.call(company: @company, params: ignore_params)
        in { errors: errors } then render json: { errors: errors }, status: :ok
        in { result: result }
          render json: Panko::Response.create { |response| json_response(response, result) }, status: :ok
        end
      end

      def destroy
        authorize! @ignore.insightable, to: :update?
        @ignore.destroy
        render json: { result: :ok }, status: :ok
      end

      private

      def json_response(response, result)
        {
          result: response.serializer(result, IgnoreSerializer)
        }
      end

      def find_company
        @company = current_user.available_write_companies.find_by!(uuid: params[:company_id])
      end

      def find_ignore
        @ignore = Ignore.find_by!(uuid: params[:id])
      end

      def ignore_params
        params.require(:ignore).permit(:entity_value)
      end
    end
  end
end
