# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :find_companies

  def index; end

  private

  def find_companies
    @companies = Current.user.companies
  end
end
