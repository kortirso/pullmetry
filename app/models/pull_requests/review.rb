# frozen_string_literal: true

module PullRequests
  class Review < ApplicationRecord
    self.table_name = :pull_requests_reviews

    ACCEPTED = 'accepted'
    REJECTED = 'rejected'
    COMMENTED = 'commented'

    belongs_to :pull_request, class_name: '::PullRequest'
    belongs_to :entity, class_name: '::Entity'

    scope :required, -> { where(required: true) }
    scope :approved, -> { where.not(review_created_at: nil) }

    enum state: { ACCEPTED => 0, REJECTED => 1, COMMENTED => 2 }
  end
end
