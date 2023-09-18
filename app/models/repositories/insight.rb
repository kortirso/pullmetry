# frozen_string_literal: true

module Repositories
  class Insight < ApplicationRecord
    self.table_name = :repositories_insights

    DEFAULT_ATTRIBUTES = %i[
      open_pull_requests_count commented_pull_requests_count reviewed_pull_requests_count merged_pull_requests_count
      average_comment_time average_review_time average_merge_time
      comments_count average_comments_count changed_loc average_changed_loc
    ].freeze

    TIME_ATTRIBUTES = %i[average_comment_time average_review_time average_merge_time].freeze
    REVERSE_ORDER_ATTRIBUTES = %i[average_comment_time average_review_time average_merge_time].freeze
    DECIMAL_ATTRIBUTES = %i[average_comments_count average_changed_loc].freeze

    SHORT_ATTRIBUTE_NAMES = {
      open_pull_requests_count: 'Open pulls',
      commented_pull_requests_count: 'Reviewed pulls',
      reviewed_pull_requests_count: 'Approved pulls',
      merged_pull_requests_count: 'Merged pulls',
      average_comment_time: 'Avg comment time',
      average_review_time: 'Avg approve time',
      average_merge_time: 'Avg merge time',
      comments_count: 'Comments',
      average_comments_count: 'Avg comments',
      changed_loc: 'Changed LOC',
      average_changed_loc: 'Avg changed LOC'
    }.freeze

    belongs_to :repository, class_name: '::Repository'

    scope :previous, -> { where.not(previous_date: nil) }
    scope :actual, -> { where(previous_date: nil) }

    def actual?
      previous_date.nil?
    end
  end
end
