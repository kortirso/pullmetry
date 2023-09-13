# frozen_string_literal: true

class Insight < ApplicationRecord
  DEFAULT_ORDER_ATTRIBUTE = :comments_count
  DEFAULT_ATTRIBUTES = %i[comments_count reviews_count average_review_seconds open_pull_requests_count].freeze

  TIME_ATTRIBUTES = %i[average_review_seconds average_merge_seconds].freeze
  DECIMAL_ATTRIBUTES = %i[average_open_pr_comments].freeze
  PERCENTILE_ATTRIBUTES = %i[review_involving].freeze

  REVERSE_ORDER_ATTRIBUTES = %i[average_review_seconds average_merge_seconds average_open_pr_comments].freeze
  SHORT_ATTRIBUTE_NAMES = {
    required_reviews_count: 'Required reviews',
    comments_count: 'Comments',
    reviews_count: 'Reviews',
    review_involving: 'Involving',
    average_review_seconds: 'Avg review time',
    reviewed_loc: 'Reviewed LOC',
    average_reviewed_loc: 'Avg review LOC',
    open_pull_requests_count: 'Open pulls',
    average_merge_seconds: 'Avg merge time',
    average_open_pr_comments: 'Avg received comments',
    changed_loc: 'Reviewed LOC',
    average_changed_loc: 'Avg review LOC'
  }.freeze

  FETCH_DAYS_PERIOD = 30
  DOUBLE_FETCH_DAYS_PERIOD = 60

  belongs_to :insightable, polymorphic: true
  belongs_to :entity

  scope :of_type, ->(type) { where(insightable_type: type) }
  scope :previous, -> { where.not(previous_date: nil) }
  scope :actual, -> { where(previous_date: nil) }

  def actual?
    previous_date.nil?
  end
end
