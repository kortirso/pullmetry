# frozen_string_literal: true

module Frontend
  class CompaniesController < Frontend::BaseController
    include Deps[add_company: 'commands.add_company']

    def create
      # commento: companies.title, companies.user_id
      case add_company.call(company_params.merge(user: user))
      in { errors: errors } then render json: { errors: errors }, status: :ok
      else render json: { redirect_path: companies_path }, status: :ok
      end
    end

    private

    def user
      return current_user if current_user.uuid == account_uuid || account_uuid.nil?

      account = User.find_by!(uuid: account_uuid)
      current_user.receive_invites.coowner.accepted.write.find_by!(inviteable_id: account.id)
      account
    end

    def account_uuid
      params[:company][:user_uuid]
    end

    def company_params
      params.require(:company).permit(:title).to_h
    end
  end
end
