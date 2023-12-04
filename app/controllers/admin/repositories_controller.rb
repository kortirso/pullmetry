# frozen_string_literal: true

module Admin
  class RepositoriesController < Admin::BaseController
    include Pagy::Backend

    PER_PAGE = 25

    before_action :find_repositories, only: %i[index]

    def index; end

    private

    def find_repositories
      @pagy, @repositories =
        pagy(
          Repository.order(id: :desc).includes(:access_token, company: %i[access_token user]),
          items: PER_PAGE
        )
    end
  end
end
