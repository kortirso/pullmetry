# frozen_string_literal: true

module Web
  class CompaniesController < ApplicationController
    include Pagy::Backend

    PER_PAGE = 5

    before_action :find_companies, only: %i[index]
    before_action :find_accounts_for_companies, only: %i[index]
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
        pagy(authorized_scope(Company.order(created_at: :desc).includes(:user)), limit: PER_PAGE)
    end

    def find_accounts_for_companies
      @accounts_for_companies =
        {
          current_user.id => 'Own account'
        }.merge(
          User
            .where(id: current_user.receive_invites.coowner.accepted.write.select(:inviteable_id))
            .pluck(:id, :email)
            .to_h
        )
    end

    def find_company
      @company = current_user.companies.find(params[:id])
    end
  end
end
