# frozen_string_literal: true

module Api
  module Frontend
    module Notifications
      class WebhooksController < Api::Frontend::BaseController
        include Deps[create_form: 'forms.webhooks.create']

        before_action :find_notification, only: %i[create]
        before_action :authorize_company, only: %i[create]

        def create
          # commento: webhooks.source, webhooks.url
          case create_form.call(webhookable: @notification, params: webhook_params)
          in { errors: errors } then render json: { errors: errors }, status: :ok
          in { result: result }
            render json: { result: WebhookSerializer.new(result).serializable_hash }, status: :ok
          end
        end

        private

        def find_notification
          @notification = Notification.find_by!(uuid: params[:notification_id])
        end

        def authorize_company
          authorized_scope(Company.order(id: :desc)).find(@notification.notifyable_id)
        end

        def webhook_params
          params.require(:webhook).permit(:url).to_h.merge(source: @notification.source)
        end
      end
    end
  end
end
