# frozen_string_literal: true

class Insight < ApplicationRecord
  DEFAULT_ATTRIBUTES = %i[required_reviews_count reviews_count average_review_seconds comments_count].freeze
  TIME_ATTRIBUTES = %i[average_review_seconds average_merge_seconds].freeze
  DECIMAL_ATTRIBUTES = %i[average_open_pr_comments].freeze
  SHORT_ATTRIBUTE_NAMES = {
    required_reviews_count: 'Required reviews',
    reviews_count: 'Total reviews',
    average_review_seconds: 'Average review time',
    comments_count: 'Total comments',
    open_pull_requests_count: 'Open PRs',
    average_merge_seconds: 'Average merge time',
    average_open_pr_comments: 'Average PR comments'
  }.freeze
  FETCH_DAYS_PERIOD = 30

  belongs_to :insightable, polymorphic: true
  belongs_to :entity

  scope :of_type, ->(type) { where(insightable_type: type) }
end
