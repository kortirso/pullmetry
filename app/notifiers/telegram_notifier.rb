# frozen_string_literal: true

class TelegramNotifier < AbstractNotifier::Base
  self.driver = proc do |data|
    Pullmetry::Container['api.telegram.client'].send_message(
      bot_secret: Rails.application.credentials.dig(:telegram_oauth, Rails.env.to_sym, :bot_secret),
      chat_id: data[:chat_id],
      text: data[:body]
    )
  end
end
