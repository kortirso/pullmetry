# frozen_string_literal: true

class Webhook < ApplicationRecord
  include Uuidable

  CUSTOM = 'custom'
  SLACK = 'slack'
  DISCORD = 'discord'

  belongs_to :insightable, polymorphic: true

  enum source: { CUSTOM => 0, SLACK => 1, DISCORD => 2 }
end
