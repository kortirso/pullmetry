# frozen_string_literal: true

class PullRequest < ApplicationRecord
  include Uuidable

  belongs_to :repository, counter_cache: true
  belongs_to :entity

  # has_many :pull_requests_entities, class_name: 'PullRequests::Entity', dependent: :destroy
  # has_many :entities, through: :pull_requests_entities
  has_many :pull_requests_comments, class_name: 'PullRequests::Comment', dependent: :destroy
  has_many :pull_requests_reviews, class_name: 'PullRequests::Review', dependent: :destroy

  scope :merged, -> { where.not(pull_merged_at: nil) }
  scope :opened, -> { where(pull_closed_at: nil) }
  scope :opened_before, lambda { |time|
    where('pull_closed_at is NULL OR pull_closed_at > :time OR created_at > :time', { time: time })
  }
  scope :closed, -> { where.not(pull_closed_at: nil) }

  def open?
    pull_closed_at.nil?
  end

  def draft?
    pull_created_at.nil?
  end
end
