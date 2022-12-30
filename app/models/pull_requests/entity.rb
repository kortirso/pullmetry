# frozen_string_literal: true

module PullRequests
  class Entity < ApplicationRecord
    self.table_name = :pull_requests_entities

    AUTHOR = 'author'
    REVIEWER = 'reviewer'

    belongs_to :pull_request, class_name: '::PullRequest'
    belongs_to :entity, class_name: '::Entity'

    has_many :pull_requests_comments,
             class_name: '::PullRequests::Comment',
             foreign_key: :pull_requests_entity_id,
             dependent: :destroy

    enum origin: { AUTHOR => 0, REVIEWER => 1 }
  end
end
