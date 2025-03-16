# frozen_string_literal: true

module Frontend
  class AccessTokensController < Frontend::BaseController
    include Deps[add_access_token: 'commands.add_access_token']

    before_action :find_company
    before_action :find_repository

    def create
      authorize! @tokenable, to: :update?

      case add_access_token.call(access_token_params.merge(tokenable: @tokenable))
      in { errors: errors } then render json: { errors: errors }, status: :ok
      else render json: { result: :ok }, status: :ok
      end
    end

    private

    def find_company
      return unless params[:company_id]

      @tokenable = Company.find(params[:company_id])
    end

    def find_repository
      return if @tokenable
      return unless params[:repository_id]

      @tokenable = current_user.repositories.find(params[:repository_id])
    end

    def access_token_params
      params.require(:access_token).permit(:value, :expired_at).to_h
    end
  end
end
