# frozen_string_literal: true

class Notification < ApplicationRecord
  include Uuidable

  REPOSITORY_ACCESS_ERROR = 'repository_access_error'
  INSIGHTS_DATA = 'insights_data'
  REPOSITORY_INSIGHTS_DATA = 'repository_insights_data'

  CUSTOM = 'custom'
  SLACK = 'slack'
  DISCORD = 'discord'
  TELEGRAM = 'telegram'

  INSIGHTABLE_SOURCES = [CUSTOM, SLACK, DISCORD, TELEGRAM].freeze
  USER_SOURCES = [TELEGRAM].freeze

  INSIGHTABLE_NOTIFICATION_TYPES = [
    REPOSITORY_ACCESS_ERROR,
    INSIGHTS_DATA,
    REPOSITORY_INSIGHTS_DATA
  ].freeze
  USER_NOTIFICATION_TYPES = [].freeze

  belongs_to :notifyable, polymorphic: true

  has_one :webhook, as: :webhookable, dependent: :destroy

  scope :enabled, -> { where(enabled: true) }

  enum notification_type: {
    REPOSITORY_ACCESS_ERROR => 0,
    INSIGHTS_DATA => 1,
    REPOSITORY_INSIGHTS_DATA => 2
  }
  enum source: { CUSTOM => 0, SLACK => 1, DISCORD => 2, TELEGRAM => 3 }
end
