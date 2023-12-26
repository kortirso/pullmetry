# frozen_string_literal: true

module Api
  module Frontend
    class InvitesController < Api::Frontend::BaseController
      include Deps[create_form: 'forms.invites.create']

      before_action :find_inviteable

      def create
        # commento: invites.email
        case create_form.call(inviteable: @inviteable, params: invite_params)
        in { errors: errors } then render json: { errors: errors }, status: :ok
        in { result: result }
          render json: { result: @inviteable.invites.hashable_pluck(:uuid, :email) }, status: :ok
        end
      end

      private

      def find_inviteable
        find_company if params[:company_id]

        page_not_found unless @inviteable
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
