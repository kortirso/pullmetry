# frozen_string_literal: true

class RepositoriesController < ApplicationController
  include Pagy::Backend

  PER_PAGE = 5

  before_action :find_repositories, only: %i[index]
  before_action :find_repository, only: %i[destroy]

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
          Repository.order(id: :desc)
        ).includes(:access_token, company: %i[access_token]),
        items: PER_PAGE
      )
  end

  def find_repository
    @repository = current_user.repositories.find_by!(uuid: params[:id])
  end
end
