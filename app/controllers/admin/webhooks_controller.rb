# frozen_string_literal: true

module Admin
  class WebhooksController < Admin::BaseController
    include Pagy::Backend

    PER_PAGE = 25

    before_action :find_webhooks, only: %i[index]

    def index; end

    private

    def find_webhooks
      @pagy, @webhooks = pagy(Webhook.order(created_at: :desc), limit: PER_PAGE)
    end
  end
end
