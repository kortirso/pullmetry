# frozen_string_literal: true

module Api
  module Frontend
    module Companies
      class UsersController < Api::Frontend::BaseController
        before_action :find_companies_user, only: %i[destroy]

        def destroy
          authorize! @companies_user.invite
          @companies_user.invite.destroy if @companies_user.invite.coworker?
          @companies_user.destroy
          render json: { result: :ok }, status: :ok
        end

        private

        def find_companies_user
          @companies_user = ::Companies::User.find_by!(uuid: params[:id])
        end
      end
    end
  end
end
