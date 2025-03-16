# frozen_string_literal: true

module Admin
  class RepositoriesController < Admin::BaseController
    include Pagy::Backend

    PER_PAGE = 25

    before_action :find_repositories, only: %i[index]
    before_action :find_repository, only: %i[destroy]

    def index; end

    def destroy
      @repository.destroy
      redirect_to admin_repositories_path
    end

    private

    def find_repositories
      @pagy, @repositories =
        pagy(
          Repository.order(created_at: :desc).includes(:access_token, company: %i[access_token]),
          limit: PER_PAGE
        )
    end

    def find_repository
      @repository = Repository.find(params[:id])
    end
  end
end
