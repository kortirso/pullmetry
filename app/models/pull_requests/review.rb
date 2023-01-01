# frozen_string_literal: true

module PullRequests
  class Review < ApplicationRecord
    self.table_name = :pull_requests_reviews

    belongs_to :pull_requests_entity, class_name: '::PullRequests::Entity', foreign_key: :pull_requests_entity_id
  end
end
