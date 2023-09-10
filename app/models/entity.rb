# frozen_string_literal: true

class Entity < ApplicationRecord
  include Uuidable
  include Providerable

  EMPTY_PAYLOAD = {
    login: 'octocat',
    html_url: 'https://github.com/octocat',
    avatar_url: 'https://avatars.githubusercontent.com/u/583231?v=4'
  }.freeze

  belongs_to :identity, optional: true

  has_many :pull_requests_entities, class_name: 'PullRequests::Entity', dependent: :destroy
  has_many :pull_requests, through: :pull_requests_entities
  has_many :pull_requests_comments, -> { distinct }, through: :pull_requests_entities
  has_many :pull_requests_reviews, -> { distinct }, through: :pull_requests_entities
  has_many :insights, dependent: :destroy
end
