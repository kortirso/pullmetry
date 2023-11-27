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
          render json: { result: { uuid: result.uuid, entity_value: result.entity_value } }, status: :ok
        end
      end

      def destroy
        authorize! @ignore.insightable, to: :update?
        @ignore.destroy
        render json: { result: :ok }, status: :ok
      end

      private

      def find_company
        @company = authorized_scope(Company.order(id: :desc)).find_by(uuid: params[:company_id])
        page_not_found if @company.nil?
      end

      def find_ignore
        @ignore = Ignore.find_by(uuid: params[:id])
        page_not_found if @ignore.nil?
      end

      def ignore_params
        params.require(:ignore).permit(:entity_value)
      end
    end
  end
end
