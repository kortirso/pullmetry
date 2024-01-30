# frozen_string_literal: true

class CompaniesController < ApplicationController
  include Pagy::Backend

  PER_PAGE = 5

  before_action :find_companies, only: %i[index]
  before_action :find_company, only: %i[destroy]

  def index; end

  def destroy
    authorize! @company
    @company.destroy
    redirect_to companies_path
  end

  private

  def find_companies
    @pagy, @companies =
      pagy(authorized_scope(Company.order(id: :desc)), items: PER_PAGE)
  end

  def find_company
    @company = current_user.companies.find_by!(uuid: params[:id])
  end
end
