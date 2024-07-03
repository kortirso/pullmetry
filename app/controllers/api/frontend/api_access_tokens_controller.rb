# frozen_string_literal: true

module Api
  module Frontend
    class ApiAccessTokensController < Api::Frontend::BaseController
      include Deps[create_form: 'forms.api_access_tokens.create']

      before_action :find_api_access_token, only: %i[destroy]

      def create
        case create_form.call(user: current_user)
        in { errors: errors } then render json: { errors: errors }, status: :ok
        in { result: result }
          render json: { result: ApiAccessTokenSerializer.new(result).serializable_hash }, status: :ok
        end
      end

      def destroy
        @api_access_token.destroy
        render json: { result: :ok }, status: :ok
      end

      private

      def find_api_access_token
        @api_access_token = current_user.api_access_tokens.find_by!(uuid: params[:id])
      end
    end
  end
end
