# frozen_string_literal: true

class Issue < ApplicationRecord
  include Uuidable

  belongs_to :repository

  has_many :comments, class_name: 'Issue::Comment', dependent: :destroy

  scope :opened_before, lambda { |time|
    where('closed_at is NULL OR closed_at > :time OR opened_at > :time', { time: time })
  }
  scope :closed, -> { where.not(closed_at: nil) }
  scope :opened, -> { where.not(opened_at: nil) }
  scope :actual, ->(fetch_period) { where('opened_at > ?', fetch_period.days.ago) }

  def open?
    closed_at.nil?
  end
end
