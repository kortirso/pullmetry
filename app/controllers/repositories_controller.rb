# frozen_string_literal: true

class RepositoriesController < ApplicationController
  include Deps[create_form: 'forms.repositories.create']
  include Pagy::Backend

  PER_PAGE = 5

  before_action :find_repositories, only: %i[index]
  before_action :find_company, only: %i[create]
  before_action :find_repository, only: %i[destroy]

  def index; end

  def new
    authorize! Current.user, to: :create_repository?
    @repository = Repository.new
    @companies = current_user.companies.pluck(:title, :uuid)
  end

  def create
    authorize! Current.user, to: :create_repository?
    # commento: repositories.title, repositories.link, repositories.provider, repositories.external_id
    case create_form.call(company: @company, params: repository_params)
    in { errors: errors } then redirect_to new_repository_path, alert: errors
    in { result: result } then redirect_to repositories_path
    end
  end

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

  def find_company
    @company = current_user.companies.find_by(uuid: params[:repository][:company_uuid])
    redirect_to new_repository_path, alert: 'Company does not exist' unless @company
  end

  def find_repository
    @repository = current_user.repositories.find_by!(uuid: params[:id])
  end

  def repository_params
    params.require(:repository).permit(:title, :link, :provider, :external_id)
  end
end
