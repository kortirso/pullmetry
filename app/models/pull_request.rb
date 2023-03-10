# frozen_string_literal: true

class PullRequest < ApplicationRecord
  include Uuidable

  belongs_to :repository, counter_cache: true
  belongs_to :entity

  has_many :pull_requests_entities, class_name: 'PullRequests::Entity', dependent: :destroy
  has_many :entities, through: :pull_requests_entities
  has_many :pull_requests_comments,
           -> { distinct },
           through: :pull_requests_entities,
           class_name: 'PullRequests::Comment'

  has_many :pull_requests_reviews,
           -> { distinct },
           through: :pull_requests_entities,
           class_name: 'PullRequests::Review'

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

  def all_entities
    Entity
      .left_joins(:pull_requests_entities)
      .where(pull_requests_entities: { pull_request_id: id })
      .or(
        Entity.where(id: entity_id)
      )
  end
end
