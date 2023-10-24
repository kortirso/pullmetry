# frozen_string_literal: true

class Insight < ApplicationRecord
  DEFAULT_ORDER_ATTRIBUTE = :comments_count
  DEFAULT_ATTRIBUTES = %i[
    comments_count reviews_count average_review_seconds open_pull_requests_count average_reviewed_loc
  ].freeze
  REVERSE_ORDER_ATTRIBUTES = %i[average_review_seconds average_merge_seconds average_open_pr_comments].freeze
  DECIMAL_ATTRIBUTES = %i[average_open_pr_comments].freeze

  FETCH_DAYS_PERIOD = 30
  DOUBLE_FETCH_DAYS_PERIOD = 60

  belongs_to :insightable, polymorphic: true
  belongs_to :entity

  scope :of_type, ->(type) { where(insightable_type: type) }
  scope :previous, -> { where.not(previous_date: nil) }
  scope :actual, -> { where(previous_date: nil) }
  scope :hidden, -> { where(hidden: true) }
  scope :visible, -> { where(hidden: false) }

  def actual?
    previous_date.nil?
  end
end
