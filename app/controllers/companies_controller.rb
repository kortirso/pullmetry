# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :find_companies, only: %i[index]
  before_action :find_company, only: %i[edit update destroy]

  def index; end

  def new
    @company = Company.new
  end

  def edit
    authorize! @company
  end

  def create
    service_call = Companies::CreateService.call(user: current_user, params: company_params)
    if service_call.success?
      redirect_to companies_path, notice: "Company #{service_call.result.title} is created"
    else
      redirect_to new_company_path, alert: service_call.errors
    end
  end

  def update
    authorize! @company
    service_call = Companies::UpdateService.call(
      company: @company,
      params: company_update_params,
      use_work_time: params[:company][:use_work_time] == '1'
    )
    if service_call.success?
      redirect_to companies_path, notice: "Company #{@company.title} is updated"
    else
      redirect_to edit_company_path(@company.uuid), alert: service_call.errors
    end
  end

  def destroy
    authorize! @company
    @company.destroy
    redirect_to companies_path, notice: "Company #{@company.title} is destroyed"
  end

  private

  def find_companies
    @companies =
      Company
      .where(user_id: current_user.id)
      .or(
        Company
        .where.not(user_id: current_user.id)
        .where(id: current_user.insights.of_type_ids('Company'))
      )
      .includes(:access_token, insights: :entity)
      .order('insights.insightable_id ASC, insights.comments_count DESC')
  end

  def find_company
    @company = current_user.companies.find_by!(uuid: params[:id])
  end

  def company_params
    return params.require(:company).permit(:title, :name) if params[:company][:use_work_time] == '0'

    params.require(:company).permit(:title, :name, :work_start_time, :work_end_time)
  end

  def company_update_params
    params.require(:company).permit(:title, :work_start_time, :work_end_time)
  end
end
