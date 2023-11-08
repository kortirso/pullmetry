# frozen_string_literal: true

module Companies
  class RepositoriesController < ApplicationController
    include Pagy::Backend

    PER_PAGE = 5

    before_action :find_company, only: %i[index]
    before_action :find_repositories, only: %i[index]

    def index
      render template: 'repositories/index'
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
          ).includes(:access_token),
          items: PER_PAGE
        )
    end
  end
end
