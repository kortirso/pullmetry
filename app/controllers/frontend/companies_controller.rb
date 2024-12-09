# frozen_string_literal: true

module Frontend
  class CompaniesController < Frontend::BaseController
    include Deps[add_company: 'commands.add_company']

    def create
      # commento: companies.title, companies.user_id
      case add_company.call(company_params.merge(user: user))
      in { errors: errors } then render json: { errors: errors }, status: :ok
      in { result: result }
        render json: Panko::Response.create { |response| json_response(response, result) }, status: :ok
      end
    end

    private

    def json_response(response, result)
      {
        result: response.serializer(result, CompanySerializer, only: %i[id])
      }
    end

    def user
      return current_user if current_user.id == account_id || account_id.nil?

      account = User.find(account_id)
      current_user.receive_invites.coowner.accepted.write.find_by!(inviteable_id: account.id)
      account
    end

    def account_id
      params[:company][:user_id]
    end

    def company_params
      params.require(:company).permit(:title).to_h
    end
  end
end
