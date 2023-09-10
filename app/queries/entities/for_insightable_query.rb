# frozen_string_literal: true

module Entities
  class ForInsightableQuery < ApplicationQuery
    def initialize(relation: Entity.none) = super

    def resolve(insightable:)
      Entity
        .left_joins(:pull_requests_entities)
        .where(pull_requests_entities: { pull_request_id: insightable.pull_requests })
        .or(
          Entity.where(id: insightable.pull_requests.select(:entity_id))
        )
    end
  end
end
