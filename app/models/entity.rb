# frozen_string_literal: true

class Entity < ApplicationRecord
  include Uuidable
  include Providerable

  belongs_to :identity, optional: true

  has_many :pull_requests_entities, class_name: 'PullRequests::Entity', dependent: :destroy
  has_many :pull_requests, through: :pull_requests_entities
  has_many :insights, dependent: :destroy
end
