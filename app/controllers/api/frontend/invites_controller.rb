# frozen_string_literal: true

module Api
  module Frontend
    class InvitesController < Api::Frontend::BaseController
      include Deps[create_form: 'forms.invites.create']

      before_action :find_inviteable, only: %i[create]
      before_action :find_invite, only: %i[destroy]

      def create
        # commento: invites.email
        case create_form.call(inviteable: @inviteable, params: invite_params)
        in { errors: errors } then render json: { errors: errors }, status: :ok
        in { result: result } then render json: { result: InviteSerializer.new(result).serializable_hash }, status: :ok
        end
      end

      def destroy
        authorize! @invite
        @invite.destroy
        render json: { result: :ok }, status: :ok
      end

      private

      def find_inviteable
        find_company if params[:company_id]

        page_not_found unless @inviteable
      end

      def find_invite
        @invite = Invite.find_by!(uuid: params[:id])
      end

      def find_company
        @inviteable = authorized_scope(Company.order(id: :desc)).find_by(uuid: params[:company_id])
      end

      def invite_params
        params.require(:invite).permit(:email)
      end
    end
  end
end
