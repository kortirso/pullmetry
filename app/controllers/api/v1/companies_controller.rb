# frozen_string_literal: true

module Api
  module V1
    class CompaniesController < Api::V1::BaseController
      include Deps[create_form: 'forms.companies.create']

      def create
        # commento: companies.title
        case create_form.call(user: current_user, params: company_params)
        in { errors: errors } then render json: { errors: errors }, status: :ok
        else render json: { redirect_path: companies_path }, status: :ok
        end
      end

      private

      def company_params
        params.require(:company).permit(:title)
      end
    end
  end
end
