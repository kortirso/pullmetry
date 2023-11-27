# frozen_string_literal: true

module Admin
  class CompaniesController < Admin::BaseController
    include Pagy::Backend

    PER_PAGE = 25

    before_action :find_companies, only: %i[index]

    def index; end

    private

    def find_companies
      @pagy, @companies = pagy(Company.includes(:access_token, :user).order(id: :desc), items: PER_PAGE)
    end
  end
end
