# frozen_string_literal: true

class PullRequest < ApplicationRecord
  include Uuidable

  belongs_to :repository, counter_cache: true

  has_many :pull_requests_entities, class_name: 'PullRequests::Entity', dependent: :destroy
  has_many :entities, through: :pull_requests_entities
end
