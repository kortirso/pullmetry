# frozen_string_literal: true

module Frontend
  module Companies
    class UsersController < Frontend::BaseController
      before_action :find_companies_user, only: %i[destroy]

      def destroy
        authorize! @companies_user.invite
        @companies_user.invite.destroy if @companies_user.invite.coworker?
        @companies_user.destroy
        render json: { result: :ok }, status: :ok
      end

      private

      def find_companies_user
        @companies_user = ::Companies::User.find(params[:id])
      end
    end
  end
end
