# frozen_string_literal: true

module Insights
  class GenerateService
    prepend ApplicationService

    def initialize(average_time_service: CalculateAverageReviewTimeService)
      @average_time_service = average_time_service
    end

    def call(insightable:)
      @insightable = insightable
      @entity_ids = @insightable.entities.pluck(:id)
      ActiveRecord::Base.transaction do
        remove_old_insights
        @entity_ids.each do |entity_id|
          insight = @insightable.insights.find_or_initialize_by(entity_id: entity_id)
          insight.update!(insight_attributes(entity_id))
        end
      end
    end

    private

    def remove_old_insights
      @insightable.insights.where.not(entity_id: @entity_ids).destroy_all
    end

    # TODO: need to add settings to company to have list of generated attributes of insights
    def insight_attributes(entity_id)
      {
        comments_count: comments_count[entity_id].to_i,
        reviews_count: reviews_count[entity_id].to_i,
        required_reviews_count: required_reviews_count[entity_id].to_i,
        open_pull_requests_count: open_pull_requests_count[entity_id].to_i,
        average_review_seconds: average_review_seconds[entity_id].to_i
      }
    end

    # this method returns { entity_id => comments_count }
    def comments_count
      @comments_count ||=
        @insightable.pull_requests_comments.joins(:pull_requests_entity).group('pull_requests_entities.entity_id').count
    end

    # this method returns { entity_id => reviews_count }
    def reviews_count
      @reviews_count ||=
        @insightable.pull_requests_reviews.joins(:pull_requests_entity).group('pull_requests_entities.entity_id').count
    end

    # this method returns { entity_id => required_reviews_count }
    def required_reviews_count
      @required_reviews_count ||= @insightable.pull_requests_entities.reviewer.group('entity_id').count
    end

    # this method returns { entity_id => open_pull_requests_count }
    def open_pull_requests_count
      @open_pull_requests_count ||= @insightable.pull_requests_entities.author.group('entity_id').count
    end

    # this method returns { entity_id => average_review_seconds }
    def average_review_seconds
      @average_review_seconds ||= @average_time_service.call(insightable: @insightable).result
    end
  end
end
