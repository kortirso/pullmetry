# frozen_string_literal: true

class Notification < ApplicationRecord
  include Uuidable

  NOTIFYABLE_TYPES = %w[
    Company
    Repository
  ].freeze

  REPOSITORY_ACCESS_ERROR = 'repository_access_error'
  INSIGHTS_DATA = 'insights_data'
  REPOSITORY_INSIGHTS_DATA = 'repository_insights_data'
  LONG_TIME_REVIEW_DATA = 'long_time_review_data'
  NO_NEW_PULLS_DATA = 'no_new_pulls_data'

  INSIGHTABLE_SOURCES = [
    Webhook::CUSTOM,
    Webhook::SLACK,
    Webhook::DISCORD,
    Webhook::TELEGRAM
  ].freeze
  USER_SOURCES = [Webhook::TELEGRAM].freeze

  INSIGHTABLE_NOTIFICATION_TYPES = [
    REPOSITORY_ACCESS_ERROR,
    INSIGHTS_DATA,
    REPOSITORY_INSIGHTS_DATA,
    LONG_TIME_REVIEW_DATA,
    NO_NEW_PULLS_DATA
  ].freeze
  USER_NOTIFICATION_TYPES = [].freeze

  belongs_to :notifyable, polymorphic: true
  belongs_to :webhook

  delegate :source, to: :webhook

  enum notification_type: {
    REPOSITORY_ACCESS_ERROR => 0,
    INSIGHTS_DATA => 1,
    REPOSITORY_INSIGHTS_DATA => 2,
    LONG_TIME_REVIEW_DATA => 3,
    NO_NEW_PULLS_DATA => 4
  }
end
