# frozen_string_literal: true

class CompaniesController < ApplicationController
  include Deps[create_form: 'forms.companies.create']
  include Pagy::Backend

  PER_PAGE = 5

  before_action :find_companies, only: %i[index]
  before_action :find_company, only: %i[destroy]

  def index; end

  def new
    @company = Company.new
  end

  def create
    # commento: companies.title
    case create_form.call(user: current_user, params: company_params)
    in { errors: errors } then redirect_to new_company_path, alert: errors
    in { result: result } then redirect_to companies_path, notice: "Company #{result.title} is created"
    end
  end

  def destroy
    authorize! @company
    @company.destroy
    redirect_to companies_path, notice: "Company #{@company.title} is destroyed"
  end

  private

  def find_companies
    @pagy, @companies =
      pagy(authorized_scope(Company.order(id: :desc)).includes(:access_token), items: PER_PAGE)
  end

  def find_company
    @company = current_user.companies.find_by!(uuid: params[:id])
  end

  def company_params
    params.require(:company).permit(:title)
  end
end
