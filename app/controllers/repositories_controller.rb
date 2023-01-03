# frozen_string_literal: true

class RepositoriesController < ApplicationController
  before_action :find_repositories, only: %i[index]
  before_action :filter_repositories, only: %i[index]
  before_action :find_company, only: %i[create]
  before_action :find_repository, only: %i[destroy]

  def index; end

  def new
    @repository = Repository.new
    @companies = Current.user.companies.pluck(:name, :uuid)
  end

  def create
    service_call = Repositories::CreateService.call(company: @company, params: repository_params)
    if service_call.success?
      redirect_to repositories_path, notice: "Repository #{service_call.result.title} is created"
    else
      redirect_to new_repository_path, alert: service_call.errors
    end
  end

  def destroy
    @repository.destroy
    redirect_to repositories_path, notice: "Repository #{@repository.title} is destroyed"
  end

  private

  def find_repositories
    @repositories =
      Repository
      .of_user(Current.user.id)
      .or(
        Repository
        .not_of_user(Current.user.id)
        .where(id: Current.user.insights.of_type_ids('Repository'))
      )
      .includes(:company, :access_token, insights: :entity)
      .order('insights.insightable_id ASC, insights.comments_count DESC')
  end

  def filter_repositories
    return unless params[:company_id]

    @repositories = @repositories.where(company_id: Company.find_by(uuid: params[:company_id]))
  end

  def find_company
    @company = Current.user.companies.find_by(uuid: params[:repository][:company_uuid])
    redirect_to new_repository_path, alert: 'Company does not exist' unless @company
  end

  def find_repository
    @repository = Current.user.repositories.find_by!(uuid: params[:id])
  end

  def repository_params
    params.require(:repository).permit(:title, :name)
  end
end
