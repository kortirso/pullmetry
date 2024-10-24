# frozen_string_literal: true

module Frontend
  module Entities
    class IgnoresController < Frontend::BaseController
      include Deps[add_entity_ignore: 'commands.add_entity_ignore']

      before_action :find_company, only: %i[create]
      before_action :find_entity_ignore, only: %i[destroy]

      def create
        case add_entity_ignore.call(entity_ignore_params.merge(insightable: @company))
        in { errors: errors } then render json: { errors: errors }, status: :ok
        in { result: result }
          render json: Panko::Response.create { |response| json_response(response, result) }, status: :ok
        end
      end

      def destroy
        authorize! @entity_ignore.insightable, to: :update?
        @entity_ignore.destroy
        render json: { result: :ok }, status: :ok
      end

      private

      def json_response(response, result)
        {
          result: response.serializer(result, Entity::IgnoreSerializer)
        }
      end

      def find_company
        @company = current_user.available_write_companies.find_by!(uuid: params[:company_id])
      end

      def find_entity_ignore
        @entity_ignore = Entity::Ignore.find_by!(uuid: params[:id])
      end

      def entity_ignore_params
        params.require(:entity_ignore).permit(:entity_value).to_h
      end
    end
  end
end
