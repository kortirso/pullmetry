# frozen_string_literal: true

class Repository < ApplicationRecord
  include Uuidable
  include Tokenable
  include Insightable

  belongs_to :company, counter_cache: true

  has_many :pull_requests, dependent: :destroy
  has_many :pull_requests_entities, -> { distinct }, class_name: '::PullRequests::Entity', through: :pull_requests
  has_many :pull_requests_comments, -> { distinct }, class_name: '::PullRequests::Comment', through: :pull_requests
  has_many :pull_requests_reviews, -> { distinct }, class_name: '::PullRequests::Review', through: :pull_requests
  has_many :entities, -> { distinct }, through: :pull_requests

  def fetch_access_token
    access_token || company.access_token
  end
end
