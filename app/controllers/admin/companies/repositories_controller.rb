# frozen_string_literal: true

module Admin
  module Companies
    class RepositoriesController < Admin::BaseController
      include Pagy::Backend

      PER_PAGE = 25

      before_action :find_company, only: %i[index]
      before_action :find_repositories, only: %i[index]

      def index
        render template: 'admin/repositories/index'
      end

      private

      def find_company
        @company = Company.find(params[:company_id])
      end

      def find_repositories
        @pagy, @repositories =
          pagy(
            @company.repositories.order(created_at: :desc).includes(:access_token),
            limit: PER_PAGE
          )
      end
    end
  end
end
