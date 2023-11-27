# frozen_string_literal: true

class Insight < ApplicationRecord
  DEFAULT_ORDER_ATTRIBUTE = :comments_count
  DEFAULT_ATTRIBUTES = %i[
    comments_count reviews_count open_pull_requests_count
    average_review_seconds average_reviewed_loc average_changed_loc
  ].freeze
  REVERSE_ORDER_ATTRIBUTES = %i[average_review_seconds average_merge_seconds average_open_pr_comments].freeze
  DECIMAL_ATTRIBUTES = %i[average_open_pr_comments].freeze

  SHORT_ATTRIBUTE_NAMES = {
    required_reviews_count: 'Required reviews',
    comments_count: 'Comments count',
    reviews_count: 'Reviews count',
    review_involving: 'Review involving',
    average_review_seconds: 'Avg review time',
    reviewed_loc: 'Reviewed LOC',
    average_reviewed_loc: 'Avg reviewed LOC',
    open_pull_requests_count: 'Open pulls',
    average_merge_seconds: 'Avg merge time',
    average_open_pr_comments: 'Avg received comments',
    changed_loc: 'Changed LOC',
    average_changed_loc: 'Avg changed LOC'
  }.freeze

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
