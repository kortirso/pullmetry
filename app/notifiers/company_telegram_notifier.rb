# frozen_string_literal: true

class CompanyTelegramNotifier < CompanyNotifier
  self.driver = proc do |data|
    Pullmetry::Container['api.telegram.client'].send_message(
      bot_secret: Rails.application.credentials.dig(Rails.env.to_sym, :oauth, :telegram, :bot_secret),
      chat_id: data[:path],
      text: data[:body]
    )
  end
end
