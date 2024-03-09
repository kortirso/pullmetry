# frozen_string_literal: true

module Api
  module Frontend
    class NotificationsController < Api::Frontend::BaseController
      include Deps[create_form: 'forms.notifications.create']

      before_action :find_notifyable, only: %i[create]
      before_action :find_notification, only: %i[destroy]

      def create
        # commento: notifications.source, notifications.notification_type
        case create_form.call(notifyable: @notifyable, params: notification_params)
        in { errors: errors } then render json: { errors: errors }, status: :ok
        in { result: result }
          render json: { result: NotificationSerializer.new(result).serializable_hash }, status: :ok
        end
      end

      def destroy
        authorize! @notification.notifyable, to: :update?
        @notification.destroy
        render json: { result: :ok }, status: :ok
      end

      private

      def find_notifyable
        find_company if params[:company_id]

        page_not_found unless @notifyable
      end

      def find_company
        @notifyable = authorized_scope(Company.order(id: :desc)).find_by!(uuid: params[:company_id])
      end

      def find_notification
        @notification = Notification.find_by!(uuid: params[:id])
      end

      def notification_params
        params.require(:notification).permit(:notification_type, :source)
      end
    end
  end
end
