# frozen_string_literal: true

module Webhooks
  class TelegramsController < ApplicationController
    include Deps[telegram_bot: 'bot.telegram.client']
    include Schemable

    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate

    def create
      telegram_bot.call(params: create_params[:message])
      head :ok
    end

    private

    def create_params
      validate_params_with_schema(params: params, schema: schema)
    end

    def schema
      Dry::Schema.Params do
        required(:message).hash do
          required(:from).hash do
            required(:first_name).filled(:string)
            required(:last_name).filled(:string)
          end
          required(:chat).hash do
            required(:id).filled
          end
          required(:text).filled(:string)
        end
      end
    end
  end
end
