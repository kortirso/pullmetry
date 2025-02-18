# frozen_string_literal: true

module Frontend
  class CompaniesController < Frontend::BaseController
    include Deps[
      add_company: 'commands.add_company',
      monitoring: 'monitoring.client'
    ]

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
        result: response.serializer(result, CompanySerializer, only: %i[uuid])
      }
    end

    def user
      monitoring_company_creation
      return current_user if current_user.uuid == account_uuid || account_uuid.nil?

      account = User.find_by!(uuid: account_uuid)
      current_user.receive_invites.coowner.accepted.write.find_by!(inviteable_id: account.id)
      account
    end

    def monitoring_company_creation
      access_token = cookies[:pullmetry_access_token].presence || params[:pullmetry_access_token]
      monitoring.notify(
        exception: 'Creating company',
        metadata: {
          access_token: access_token,
          current_user: current_user.uuid,
          account_uuid: account_uuid,
          company_params: company_params
        },
        severity: :info
      )
    end

    def account_uuid
      params[:company][:user_uuid]
    end

    def company_params
      params.require(:company).permit(:title).to_h
    end
  end
end
