# frozen_string_literal: true

module Entities
  class ForInsightableQuery < ApplicationQuery
    def initialize(relation: Entity.none) = super

    def resolve(insightable:)
      relation = Entity.left_joins(:comments, :reviews)

      relation.where(pull_requests_comments: { pull_request_id: insightable.pull_requests })
        .or(relation.where(pull_requests_reviews: { pull_request_id: insightable.pull_requests }))
        .or(Entity.where(id: insightable.pull_requests.select(:entity_id)))
        .distinct
    end
  end
end
