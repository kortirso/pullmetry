# frozen_string_literal: true

module Web
  class RepositoriesController < ApplicationController
    include Pagy::Backend

    PER_PAGE = 5

    before_action :find_repositories, only: %i[index]
    before_action :find_repository, only: %i[destroy]
    before_action :find_available_companies, only: %i[index]

    def index; end

    def destroy
      authorize! @repository
      @repository.destroy
      redirect_to repositories_path
    end

    private

    def find_repositories
      @pagy, @repositories =
        pagy(
          authorized_scope(
            Repository.order(created_at: :desc)
          ).includes(:access_token, company: %i[access_token user]),
          limit: PER_PAGE
        )
    end

    def find_repository
      @repository = current_user.repositories.find(params[:id])
    end

    def find_available_companies
      @available_companies =
        current_user.companies
          .or(
            Company.where(id: current_user.companies_users.write.select(:company_id))
          )
          .pluck(:id, :title)
          .to_h
    end
  end
end
