# frozen_string_literal: true

module Api
  module Frontend
    class RepositoriesController < Api::Frontend::BaseController
      include Deps[create_form: 'forms.repositories.create']

      before_action :find_company, only: %i[create]

      def create
        authorize! current_user, to: :create_repository?
        # commento: repositories.title, repositories.link, repositories.provider, repositories.external_id
        case create_form.call(company: @company, params: repository_params)
        in { errors: errors } then render json: { errors: errors }, status: :ok
        else render json: { redirect_path: repositories_path }, status: :ok
        end
      end

      private

      def find_company
        @company = current_user.companies.find_by!(uuid: params[:repository][:company_uuid])
      end

      def repository_params
        params.require(:repository).permit(:title, :link, :provider, :external_id)
      end
    end
  end
end
