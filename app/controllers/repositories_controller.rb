# frozen_string_literal: true

class RepositoriesController < ApplicationController
  before_action :find_repositories

  def index; end

  private

  def find_repositories
    @repositories = Current.user.repositories.includes(:company)
    return unless params[:company_id]

    @repositories = @repositories.where(company_id: Current.user.companies.find_by(uuid: params[:company_id]))
  end
end
