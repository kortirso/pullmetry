# frozen_string_literal: true

class DiscordWebhookNotifier < AbstractNotifier::Base
  include Deps[discord_client: 'api.discord.client']

  self.driver = proc do |data|
    discord_client.send_message(
      path: data[:path],
      body: data[:body]
    )
  end
end
