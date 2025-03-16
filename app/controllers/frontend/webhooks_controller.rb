# frozen_string_literal: true

module Frontend
  class WebhooksController < Frontend::BaseController
    include Deps[add_webhook: 'commands.add_webhook']

    before_action :find_company, only: %i[create]
    before_action :find_webhook, only: %i[destroy]

    def create
      # commento: webhooks.source, webhooks.url, webhooks.company_id
      case add_webhook.call(webhook_params.merge(company: @company))
      in { errors: errors } then render json: { errors: errors }, status: :ok
      in { result: result }
        render json: Panko::Response.create { |response| json_response(response, result) }, status: :ok
      end
    end

    def destroy
      authorize! @webhook.company, to: :update?
      @webhook.destroy
      render json: { result: :ok }, status: :ok
    end

    private

    def json_response(response, result)
      {
        result: response.serializer(result, WebhookSerializer)
      }
    end

    def find_company
      @company = current_user.available_write_companies.find(params[:company_id])
    end

    def find_webhook
      @webhook = Webhook.find(params[:id])
    end

    def webhook_params
      params.require(:webhook).permit(:source, :url).to_h
    end
  end
end
