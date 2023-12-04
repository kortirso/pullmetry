# frozen_string_literal: true

class ApplicationDelivery < ActiveDelivery::Base
  self.abstract_class = true

  register_line :webhook, ActiveDelivery::Lines::Notifier,
                resolver_pattern: 'Webhooks::%{delivery_name}Notifier'

  register_line :slack_webhook, ActiveDelivery::Lines::Notifier,
                resolver_pattern: 'SlackWebhooks::%{delivery_name}Notifier'

  register_line :discord_webhook, ActiveDelivery::Lines::Notifier,
                resolver_pattern: 'DiscordWebhooks::%{delivery_name}Notifier'
end
