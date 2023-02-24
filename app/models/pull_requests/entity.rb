# frozen_string_literal: true

module PullRequests
  class Entity < ApplicationRecord
    self.table_name = :pull_requests_entities

    belongs_to :pull_request, class_name: '::PullRequest'
    belongs_to :entity, class_name: '::Entity'

    has_many :pull_requests_comments,
             class_name: '::PullRequests::Comment',
             foreign_key: :pull_requests_entity_id,
             dependent: :destroy

    has_many :pull_requests_reviews,
             class_name: '::PullRequests::Review',
             foreign_key: :pull_requests_entity_id,
             dependent: :destroy
  end
end
