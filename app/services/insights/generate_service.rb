# frozen_string_literal: true

module Insights
  class GenerateService
    prepend ApplicationService

    def initialize(
      average_review_time_service: AverageTime::ForReviewService,
      average_merge_time_service: AverageTime::ForMergeService
    )
      @average_review_time_service = average_review_time_service
      @average_merge_time_service = average_merge_time_service
    end

    def call(insightable:)
      @insightable = insightable
      ActiveRecord::Base.transaction do
        remove_old_insights
        entity_ids.each do |entity_id|
          insight = @insightable.insights.find_or_initialize_by(entity_id: entity_id)
          insight.update!(insight_attributes(entity_id))
        end
      end
    end

    private

    def entity_ids
      @entity_ids ||= @insightable.entities.pluck(:id)
    end

    def remove_old_insights
      @insightable.insights.where.not(entity_id: entity_ids).destroy_all
    end

    # this method generates insight attributes based on available insight_fields
    def insight_attributes(entity_id)
      insight_fields.inject({}) { |acc, insight_field| acc.merge({ insight_field => send(insight_field)[entity_id] }) }
    end

    # selecting insight attributes based on company configuration
    def insight_fields
      @insight_fields ||=
        if @insightable.premium? && @insightable.configuration.insight_fields.present?
          @insightable.configuration.insight_fields.attributes.filter_map { |key, value| value ? key.to_sym : nil }
        else
          Insight::DEFAULT_ATTRIBUTES
        end
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
      @average_review_seconds ||= @average_review_time_service.call(insightable: @insightable).result
    end

    # this method returns { entity_id => average_merge_seconds }
    def average_merge_seconds
      @average_merge_seconds ||= @average_merge_time_service.call(insightable: @insightable).result
    end
  end
end
