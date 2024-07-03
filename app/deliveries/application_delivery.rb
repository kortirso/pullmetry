# frozen_string_literal: true

class ApplicationDelivery < ActiveDelivery::Base
  self.abstract_class = true

  unregister_line :mailer

  register_line :webhook, ActiveDelivery::Lines::Notifier,
                resolver_pattern: '%{delivery_name}WebhookNotifier'

  register_line :slack, ActiveDelivery::Lines::Notifier,
                resolver_pattern: '%{delivery_name}SlackNotifier'

  register_line :discord, ActiveDelivery::Lines::Notifier,
                resolver_pattern: '%{delivery_name}DiscordNotifier'

  register_line :telegram, ActiveDelivery::Lines::Notifier,
                resolver_pattern: '%{delivery_name}TelegramNotifier'
end
