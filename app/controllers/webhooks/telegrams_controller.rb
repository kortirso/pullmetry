# frozen_string_literal: true

module Webhooks
  class TelegramsController < ApplicationController
    include Deps[telegram_bot: 'bot.telegram.client']
    include Parameterable

    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate

    def create
      telegram_bot.call(params: create_params)
      head :ok
    end

    private

    def create_params
      schema_params(params: params, schema: Webhooks::TelegramSchema)[:message]
    end
  end
end
