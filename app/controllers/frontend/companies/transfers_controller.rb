# frozen_string_literal: true

module Frontend
  module Companies
    class TransfersController < Frontend::BaseController
      before_action :find_company
      before_action :find_target_user

      def create
        if allowed_to?(:create_repository?, @user, context: { amount: @company.repositories_count.to_i })
          # commento: companies.user_id
          @company.update!(user: @user)
          render json: { redirect_path: companies_path }, status: :ok
        else
          render json: { errors: ['Company can not be transfered'] }, status: :ok
        end
      end

      private

      def find_company
        @company = current_user.companies.find_by!(uuid: params[:company_id])
      end

      def find_target_user
        @user = ::User.where.not(id: current_user.id).find_by!(uuid: params[:user_uuid])
      end
    end
  end
end
