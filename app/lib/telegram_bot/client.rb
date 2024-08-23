# frozen_string_literal: true

module TelegramBot
  class Client
    include Deps[telegram_api: 'api.telegram.client']

    def call(params: {})
      case params[:text]
      when '/help' then send_help_message(params[:chat])
      when '/start' then send_start_message(params[:from], params[:chat])
      when '/get_chat_id' then send_chat_id_message(params[:chat])
      else send_unknown_message(params[:chat])
      end
    end

    private

    def send_help_message(chat)
      telegram_api.send_message(
        bot_secret: bot_secret,
        chat_id: chat[:id],
        text: "Available commands are:\n/start\n/help\n/get_chat_id"
      )
    end

    def send_start_message(sender, chat)
      telegram_api.send_message(
        bot_secret: bot_secret,
        chat_id: chat[:id],
        text: "Hello, #{sender[:first_name]} #{sender[:last_name]}\nTo see list of commands type /help"
      )
    end

    def send_chat_id_message(chat)
      telegram_api.send_message(
        bot_secret: bot_secret,
        chat_id: chat[:id],
        text: "Chat id is #{chat[:id]}"
      )
    end

    def send_unknown_message(chat)
      telegram_api.send_message(
        bot_secret: bot_secret,
        chat_id: chat[:id],
        text: "I don't know what to say, sorry :("
      )
    end

    def bot_secret
      @bot_secret ||= Rails.application.credentials.dig(Rails.env.to_sym, :oauth, :telegram, :bot_secret)
    end
  end
end
