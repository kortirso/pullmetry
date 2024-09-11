# frozen_string_literal: true

module Frontend
  class InvitesController < Frontend::BaseController
    include Deps[add_invite: 'commands.add_invite']

    before_action :find_inviteable, only: %i[create]
    before_action :find_invite, only: %i[destroy]

    def create
      # commento: invites.email, invites.access
      case add_invite.call(invite_params.merge(inviteable: @inviteable))
      in { errors: errors } then render json: { errors: errors }, status: :ok
      in { result: result }
        render json: Panko::Response.create { |response| json_response(response, result) }, status: :ok
      end
    end

    def destroy
      authorize! @invite
      @invite.destroy
      render json: { result: :ok }, status: :ok
    end

    private

    def json_response(response, result)
      {
        result: response.serializer(result, InviteSerializer)
      }
    end

    def find_inviteable
      @inviteable = params[:company_id] ? find_company : find_user

      page_not_found unless @inviteable
    end

    def find_invite
      @invite = Invite.find_by!(uuid: params[:id])
    end

    def find_company
      current_user.available_write_companies.find_by(uuid: params[:company_id])
    end

    def find_user
      current_user
    end

    def invite_params
      params.require(:invite).permit(:email, :access).to_h
    end
  end
end
