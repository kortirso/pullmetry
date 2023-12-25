# frozen_string_literal: true

class PullRequest < ApplicationRecord
  include Uuidable

  belongs_to :repository
  belongs_to :entity

  has_many :pull_requests_comments, class_name: 'PullRequests::Comment', dependent: :destroy
  has_many :pull_requests_reviews, class_name: 'PullRequests::Review', dependent: :destroy

  scope :merged, -> { where.not(pull_merged_at: nil) }
  scope :opened, -> { where(pull_closed_at: nil) }
  scope :opened_before, lambda { |time|
    where('pull_closed_at is NULL OR pull_closed_at > :time OR created_at > :time', { time: time })
  }
  scope :closed, -> { where.not(pull_closed_at: nil) }
  scope :created, -> { where.not(pull_created_at: nil) }
  scope :actual, ->(fetch_period) { where('pull_created_at > ?', fetch_period.days.ago) }

  def open?
    pull_closed_at.nil?
  end

  def draft?
    pull_created_at.nil?
  end
end
