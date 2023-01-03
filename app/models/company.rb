# frozen_string_literal: true

class Company < ApplicationRecord
  include Uuidable
  include Tokenable
  include Insightable

  belongs_to :user

  has_many :repositories, dependent: :destroy
  has_many :pull_requests, -> { distinct }, through: :repositories
  has_many :entities, -> { distinct }, through: :repositories
  has_many :pull_requests_entities, -> { distinct }, class_name: '::PullRequests::Entity', through: :repositories
  has_many :pull_requests_comments, -> { distinct }, class_name: '::PullRequests::Comment', through: :repositories
  has_many :pull_requests_reviews, -> { distinct }, class_name: '::PullRequests::Review', through: :repositories

  def with_work_time?
    work_start_time.present? && work_end_time.present?
  end
end
