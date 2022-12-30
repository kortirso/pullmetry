# frozen_string_literal: true

class Entity < ApplicationRecord
  include Uuidable

  GITHUB = 'github'

  enum source: { GITHUB => 0 }

  has_many :pull_requests_entities, class_name: 'PullRequests::Entity', dependent: :destroy
  has_many :pull_requests, through: :pull_requests_entities
end
