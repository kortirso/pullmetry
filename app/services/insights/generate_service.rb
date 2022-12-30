# frozen_string_literal: true

module Insights
  class GenerateService
    prepend ApplicationService

    def call(insightable:)
      @insightable = insightable
      ActiveRecord::Base.transaction do
        @insightable.entities.find_each do |entity|
          insight = @insightable.insights.find_or_initialize_by(entity: entity)
          # TODO: need to add settings to company to have list of generated attributes of insights
          insight.update!(
            comments_count: comments_count[entity.id].to_i
          )
        end
      end
    end

    private

    # this method returns { entity_id => comments_count }
    def comments_count
      @comments_count ||=
        @insightable.pull_requests_comments.joins(:pull_requests_entity).group('pull_requests_entities.entity_id').count
    end
  end
end
