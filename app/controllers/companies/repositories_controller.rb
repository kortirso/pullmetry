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
      @company = current_user.companies.find_by!(uuid: params[:company_id])
    end

    def find_repositories
      @pagy, @repositories =
        pagy(
          authorized_scope(
            @company.repositories.order(id: :desc)
          ).includes(:access_token, :repository_insights, company: %i[user access_token]),
          items: PER_PAGE
        )
    end
  end
end
