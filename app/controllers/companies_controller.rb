# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :find_companies, only: %i[index]
  before_action :find_company, only: %i[destroy]

  def index; end

  def new
    @company = Company.new
  end

  def create
    service_call = Companies::CreateService.call(user: Current.user, params: company_params)
    if service_call.success?
      redirect_to companies_path, notice: "Company #{service_call.result.title} is created"
    else
      redirect_to new_company_path, alert: service_call.errors
    end
  end

  def destroy
    @company.destroy
    redirect_to companies_path, notice: "Company #{@company.title} is destroyed"
  end

  private

  def find_companies
    @companies = Current.user.companies
  end

  def find_company
    @company = Current.user.companies.find_by!(uuid: params[:id])
  end

  def company_params
    params.require(:company).permit(:title, :name)
  end
end
