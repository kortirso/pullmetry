# frozen_string_literal: true

module Api
  module Frontend
    class WebhooksController < Api::Frontend::BaseController
      include Deps[create_form: 'forms.webhooks.create']

      before_action :find_company, only: %i[create]
      before_action :find_webhook, only: %i[destroy]

      def create
        # commento: webhooks.source, webhooks.url
        case create_form.call(company: @company, params: webhook_params)
        in { errors: errors } then render json: { errors: errors }, status: :ok
        in { result: result }
          render json: { result: { uuid: result.uuid, source: result.source, url: result.url } }, status: :ok
        end
      end

      def destroy
        authorize! @webhook.webhookable, to: :update?
        @webhook.destroy
        @webhook.webhookable.notifications.where(source: @webhook.source).destroy_all
        render json: { result: :ok }, status: :ok
      end

      private

      def find_company
        @company = authorized_scope(Company.order(id: :desc)).find_by!(uuid: params[:company_id])
      end

      def find_webhook
        @webhook = Webhook.find_by!(uuid: params[:id])
      end

      def webhook_params
        params.require(:webhook).permit(:source, :url)
      end
    end
  end
end
