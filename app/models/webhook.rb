# frozen_string_literal: true

class Webhook < ApplicationRecord
  include Uuidable

  CUSTOM = 'custom'
  SLACK = 'slack'
  DISCORD = 'discord'
  TELEGRAM = 'telegram'

  belongs_to :webhookable, polymorphic: true # Company/Repository/Notification

  enum source: { CUSTOM => 0, SLACK => 1, DISCORD => 2, TELEGRAM => 3 }
end
