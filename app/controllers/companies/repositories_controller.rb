# frozen_string_literal: true

module Companies
  class RepositoriesController < ApplicationController
    include Pagy::Backend

    PER_PAGE = 5

    before_action :find_company
    before_action :find_repositories, only: %i[index]

    def index
      render template: 'repositories/index'
    end

    def new
      authorize! Current.user, to: :create_repository?
      @repository = @company.repositories.new
      @companies = current_user.companies.pluck(:title, :uuid)

      render template: 'repositories/new'
    end

    private

    def find_company
      @company = authorized_scope(Company.all).find_by!(uuid: params[:company_id])
    end

    def find_repositories
      @pagy, @repositories =
        pagy(
          authorized_scope(
            @company.repositories.order(id: :desc)
          ).includes(:access_token, :repository_insights),
          items: PER_PAGE
        )
    end
  end
end
