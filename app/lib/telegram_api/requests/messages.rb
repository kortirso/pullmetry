# frozen_string_literal: true

module TelegramApi
  module Requests
    module Messages
      def send_message(bot_secret:, chat_id:, text:)
        get(
          path: "bot#{bot_secret}/sendMessage?chat_id=#{chat_id}&text=#{text}",
          headers: headers
        )
      end
    end
  end
end
