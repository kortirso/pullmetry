# frozen_string_literal: true

module Api
  module Frontend
    class NotificationsController < Api::Frontend::BaseController
      include Deps[create_form: 'forms.notifications.create']

      before_action :find_notifyable
      before_action :find_notification

      def create
        return refresh_notifications if @notification

        # commento: notifications.source, notifications.notification_type
        case create_form.call(notifyable: @notifyable, params: notification_params)
        in { errors: errors } then render json: { errors: errors }, status: :ok
        in { result: result } then render_enabled_notifications
        end
      end

      def destroy
        return page_not_found if @notification.nil?

        # commento: notifications.enabled
        @notification.update(enabled: false)
        render_enabled_notifications
      end

      private

      def find_notifyable
        find_company if params[:company_id]

        page_not_found unless @notifyable
      end

      def find_notification
        @notification = @notifyable.notifications.find_by(notification_params)
      end

      def find_company
        @notifyable = authorized_scope(Company.order(id: :desc)).find_by!(uuid: params[:company_id])
      end

      def refresh_notifications
        # commento: notifications.enabled
        @notification.update(enabled: true)
        render_enabled_notifications
      end

      def render_enabled_notifications
        render json: {
          result: @notifyable.notifications.hashable_pluck(:uuid, :source, :notification_type, :enabled)
        }, status: :ok
      end

      def notification_params
        params.require(:notification).permit(:notification_type, :source)
      end
    end
  end
end
