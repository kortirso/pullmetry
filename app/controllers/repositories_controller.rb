# frozen_string_literal: true

class RepositoriesController < ApplicationController
  before_action :find_repositories, only: %i[index]
  before_action :find_repository, only: %i[show]

  def index; end

  def show; end

  private

  def find_repositories
    @repositories = Current.user.repositories.includes(:company)
    return unless params[:company_id]

    @repositories = @repositories.where(company_id: Current.user.companies.find_by(uuid: params[:company_id]))
  end

  def find_repository
    @repository = Current.user.repositories.find_by!(uuid: params[:id])
  end
end
