# frozen_string_literal: true

module Api
  module Frontend
    class NotificationsController < Api::Frontend::BaseController
      include Deps[create_form: 'forms.notifications.create']

      before_action :find_company, only: %i[create]
      before_action :find_webhook, only: %i[create]
      before_action :find_notification, only: %i[destroy]

      def create
        # commento: notifications.webhook_id, notifications.notification_type
        case create_form.call(notifyable: @company, webhook: @webhook, params: notification_params)
        in { errors: errors } then render json: { errors: errors }, status: :ok
        in { result: result }
          render json: Panko::Response.create { |response| json_response(response, result) }, status: :ok
        end
      end

      def destroy
        authorize! @notification.notifyable, to: :update?
        @notification.destroy
        render json: { result: :ok }, status: :ok
      end

      private

      def json_response(response, result)
        {
          result: response.serializer(result, NotificationSerializer)
        }
      end

      def find_company
        @company = current_user.available_write_companies.find_by!(uuid: params[:company_id])
      end

      def find_webhook
        @webhook = @company.webhooks.find_by!(uuid: params[:webhook_id])
      end

      def find_notification
        @notification = Notification.find_by!(uuid: params[:id])
      end

      def notification_params
        params.require(:notification).permit(:notification_type)
      end
    end
  end
end
