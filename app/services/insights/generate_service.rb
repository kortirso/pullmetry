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
      insight_fields.inject({}) do |acc, insight_field|
        unless insight_field.ends_with?('ratio')
          next acc.merge({ insight_field.to_sym => send(insight_field)[entity_id].to_i })
        end

        acc.merge({ insight_field.to_sym => send(:ratio, insight_field[0..-7], entity_id) })
      end
    end

    # selecting insight attributes based on company configuration
    def insight_fields
      @insight_fields ||= begin
        list =
          if premium && configuration.insight_fields.present?
            @insightable.selected_insight_fields
          else
            Insight::DEFAULT_ATTRIBUTES
          end

        if premium && configuration.insight_ratio
          list = list.flat_map { |insight_field| [insight_field, "#{insight_field}_ratio"] }
        end

        list
      end
    end

    def ratio(insight_field, entity_id)
      previous_period = send(insight_field, Insight::FETCH_DAYS_PERIOD * 2, Insight::FETCH_DAYS_PERIOD)[entity_id].to_i
      return 0 if previous_period.zero?

      (send(insight_field)[entity_id] - previous_period) * 100 / previous_period
    end

    # this method returns { entity_id => comments_count }
    def comments_count(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
      @comments_count ||= {}

      @comments_count.fetch("#{date_from},#{date_to}") do |key|
        @comments_count[key] =
          @insightable
          .pull_requests_comments
          .joins(pull_requests_entity: :pull_request)
          .where(
            'pull_requests.pull_created_at > ? AND pull_requests.pull_created_at < ?',
            date_from.days.ago,
            date_to.days.ago
          )
          .group('pull_requests_entities.entity_id').count
      end
    end

    # this method returns { entity_id => reviews_count }
    def reviews_count(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
      @reviews_count ||= {}

      @reviews_count.fetch("#{date_from},#{date_to}") do |key|
        @reviews_count[key] =
          @insightable
          .pull_requests_reviews
          .joins(pull_requests_entity: :pull_request)
          .where(
            'pull_requests.pull_created_at > ? AND pull_requests.pull_created_at < ?',
            date_from.days.ago,
            date_to.days.ago
          )
          .group('pull_requests_entities.entity_id').count
      end
    end

    # this method returns { entity_id => required_reviews_count }
    def required_reviews_count(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
      @required_reviews_count ||= {}

      @required_reviews_count.fetch("#{date_from},#{date_to}") do |key|
        @required_reviews_count[key] =
          @insightable
          .pull_requests_entities.reviewer
          .joins(:pull_request)
          .where(
            'pull_requests.pull_created_at > ? AND pull_requests.pull_created_at < ?',
            date_from.days.ago,
            date_to.days.ago
          )
          .group('entity_id').count
      end
    end

    # this method returns { entity_id => open_pull_requests_count }
    def open_pull_requests_count(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
      @open_pull_requests_count ||= {}

      @open_pull_requests_count.fetch("#{date_from},#{date_to}") do |key|
        @open_pull_requests_count[key] =
          @insightable
          .pull_requests_entities.author
          .joins(:pull_request)
          .where(
            'pull_requests.pull_created_at > ? AND pull_requests.pull_created_at < ?',
            date_from.days.ago,
            date_to.days.ago
          )
          .group('entity_id').count
      end
    end

    # this method returns { entity_id => average_review_seconds }
    def average_review_seconds(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
      @average_review_seconds ||= {}

      @average_review_seconds.fetch("#{date_from},#{date_to}") do |key|
        @average_review_seconds[key] =
          @average_review_time_service.call(insightable: @insightable, date_from: date_from, date_to: date_to).result
      end
    end

    # this method returns { entity_id => average_merge_seconds }
    def average_merge_seconds(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
      @average_merge_seconds ||= {}

      @average_merge_seconds.fetch("#{date_from},#{date_to}") do |key|
        @average_merge_seconds[key] =
          @average_merge_time_service.call(insightable: @insightable, date_from: date_from, date_to: date_to).result
      end
    end

    def premium
      @insightable.premium?
    end

    def configuration
      @configuration ||= @insightable.configuration
    end
  end
end
