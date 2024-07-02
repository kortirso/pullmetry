# frozen_string_literal: true

module Api
  module Frontend
    class WebhooksController < Api::Frontend::BaseController
      include Deps[create_form: 'forms.webhooks.create']

      before_action :find_webhookable, only: %i[create]
      before_action :find_webhook, only: %i[destroy]

      def create
        # commento: webhooks.source, webhooks.url
        case create_form.call(webhookable: @webhookable, params: webhook_params)
        in { errors: errors } then render json: { errors: errors }, status: :ok
        in { result: result }
          render json: { result: WebhookSerializer.new(result).serializable_hash }, status: :ok
        end
      end

      def destroy
        webhookable = @webhook.webhookable
        authorize! (webhookable.is_a?(Notification) ? webhookable.notifyable : webhookable), to: :update?
        @webhook.destroy
        render json: { result: :ok }, status: :ok
      end

      private

      def find_webhookable
        find_company if params[:company_id]
        if params[:notification_id]
          find_notification
          authorize_company
        end

        page_not_found unless @webhookable
      end

      def find_company
        @webhookable = current_user.available_write_companies.find_by!(uuid: params[:company_id])
      end

      def find_notification
        @webhookable = Notification.find_by!(uuid: params[:notification_id])
      end

      def authorize_company
        current_user.available_write_companies.find(@webhookable.notifyable_id)
      end

      def find_webhook
        @webhook = Webhook.find_by!(uuid: params[:id])
      end

      def webhook_params
        hashable_params = params.require(:webhook).permit(:source, :url).to_h
        hashable_params[:source] = @webhookable.source if @webhookable.is_a?(Notification)
        hashable_params
      end
    end
  end
end
