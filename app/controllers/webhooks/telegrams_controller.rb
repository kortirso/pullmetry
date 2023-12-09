# frozen_string_literal: true

module Webhooks
  class TelegramsController < ApplicationController
    include Deps[telegram_bot: 'bot.telegram.client']

    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate

    def create
      return head :ok unless message

      telegram_bot.call(
        sender: message[:from].permit!.to_h,
        chat: message[:chat].permit!.to_h,
        text: message[:text]
      )
      head :ok
    end

    private

    def message
      params[:message]
    end
  end
end
