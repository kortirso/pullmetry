# frozen_string_literal: true

class DiscordWebhookNotifier < AbstractNotifier::Base
  self.driver = proc do |data|
    Pullmetry::Container['api.discord.client'].send_message(
      path: data[:path],
      body: data[:body]
    )
  end
end
