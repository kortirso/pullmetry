# frozen_string_literal: true

class Insight < ApplicationRecord
  DEFAULT_ATTRIBUTES = %i[required_reviews_count reviews_count average_review_seconds comments_count].freeze

  belongs_to :insightable, polymorphic: true
  belongs_to :entity

  scope :of_type, ->(type) { where(insightable_type: type) }
end
