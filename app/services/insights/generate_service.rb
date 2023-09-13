# frozen_string_literal: true

module Insights
  class GenerateService
    prepend ApplicationService

    def initialize(
      average_review_time_service: AverageTime::ForReviewService,
      average_merge_time_service: AverageTime::ForMergeService,
      find_average_service: Math::Average.new
    )
      @average_review_time_service = average_review_time_service
      @average_merge_time_service = average_merge_time_service
      @find_average_service = find_average_service
    end

    def call(insightable:)
      @insightable = insightable
      previous_insight_date = Insight::DOUBLE_FETCH_DAYS_PERIOD.days.ago.to_date.to_s

      ActiveRecord::Base.transaction do
        remove_old_insights(previous_insight_date)
        entity_ids.each do |entity_id|
          generate_previous_insight(entity_id, previous_insight_date)

          # update actual insight information for current period
          insight = @insightable.insights.actual.find_or_initialize_by(entity_id: entity_id)
          insight.update!(insight_attributes(entity_id))
        end
      end
    end

    private

    def entity_ids
      @entity_ids ||= Entities::ForInsightableQuery.resolve(insightable: @insightable).pluck(:id)
    end

    def remove_old_insights(previous_insight_date)
      @insightable.insights.where.not(entity_id: entity_ids).destroy_all
      @insightable.insights.previous.where.not(previous_date: previous_insight_date).destroy_all
    end

    def generate_previous_insight(entity_id, previous_insight_date)
      # update insight information for previous period
      return @previous_insight = nil if !premium || !configuration.insight_ratio

      # create previous insight for date only once per entity
      @previous_insight = @insightable.insights.find_by(entity_id: entity_id, previous_date: previous_insight_date)
      return unless @previous_insight.nil?

      # commento: insights.previous_date
      @previous_insight = @insightable.insights.find_or_initialize_by(
        entity_id: entity_id,
        previous_date: previous_insight_date
      )
      @previous_insight.update!(insight_attributes(entity_id, true))
    end

    # this method generates insight attributes based on available insight_fields
    # rubocop: disable Style/OptionalBooleanParameter
    def insight_attributes(entity_id, previous=false)
      active_fields(previous).inject({}) do |acc, insight_field|
        field_value =
          if insight_field.ends_with?('ratio')
            method_name = configuration.insight_ratio_type == 'ratio' ? :ratio : :change
            send(method_name, insight_field[0..-7], entity_id)
          else
            value = find_insight_field_value(insight_field, entity_id, previous)
            Insight::DECIMAL_ATTRIBUTES.include?(insight_field.to_sym) ? value.to_f : value.to_i
          end

        acc.merge({ insight_field.to_sym => field_value })
      end
    end
    # rubocop: enable Style/OptionalBooleanParameter

    def active_fields(previous)
      previous ? previous_insight_fields : insight_fields
    end

    def find_insight_field_value(insight_field, entity_id, previous)
      return send(insight_field, Insight::DOUBLE_FETCH_DAYS_PERIOD, Insight::FETCH_DAYS_PERIOD)[entity_id] if previous

      send(insight_field)[entity_id]
    end

    # selecting insight attributes based on company configuration
    def insight_fields
      @insight_fields ||= begin
        list = previous_insight_fields
        if premium && configuration.insight_ratio
          list = list.flat_map { |insight_field| [insight_field, "#{insight_field}_ratio"] }
        end
        list
      end
    end

    # selecting previous insight attributes based on company configuration
    def previous_insight_fields
      @previous_insight_fields ||=
        if premium && configuration.insight_fields.present?
          @insightable.selected_insight_fields
        else
          Insight::DEFAULT_ATTRIBUTES
        end
    end

    def ratio(insight_field, entity_id)
      return 0 if @previous_insight.nil?

      previous_period = @previous_insight[insight_field].to_i
      return 0 if previous_period.zero?

      (send(insight_field)[entity_id].to_i - previous_period) * 100 / previous_period
    end

    def change(insight_field, entity_id)
      return 0 if @previous_insight.nil?

      send(insight_field)[entity_id].to_i - @previous_insight[insight_field].to_i
    end

    # this method returns { entity_id => comments_count_by_entity }
    def comments_count(...) = raise NotImplementedError

    # this method returns { entity_id => reviews_count }
    def reviews_count(...) = raise NotImplementedError

    # this method returns { entity_id => required_reviews_count }
    def required_reviews_count(...) = raise NotImplementedError

    # this method returns { entity_id => review_involving }
    def review_involving(...) = raise NotImplementedError

    # this method returns { entity_id => open_pull_requests_count }
    def open_pull_requests_count(...) = raise NotImplementedError

    def pulls_with_user_comments(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
      @pulls_with_user_comments ||= {}

      @pulls_with_user_comments.fetch("#{date_from},#{date_to}") do |key|
        @pulls_with_user_comments[key] =
          @insightable
            .pull_requests
            .where(
              'pull_created_at > ? AND pull_created_at < ?',
              beginning_of_date('from', date_from),
              date_to.zero? ? DateTime.now : beginning_of_date('to', date_to)
            )
            .flat_map { |pull|
              Entity
                .joins(:pull_requests_comments)
                .where(pull_requests_comments: { id: pull.pull_requests_comments })
                .pluck(:id)
                .uniq
            }.tally
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

    def average_open_pr_comments(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
      @average_open_pr_comments ||= {}

      @average_open_pr_comments.fetch("#{date_from},#{date_to}") do |key|
        @average_open_pr_comments[key] =
          sum_comments_in_open_prs(date_from, date_to).transform_values { |value|
            @find_average_service.call(values: value, type: @insightable.configuration.average_type, round: 2)
          }
      end
    end

    def sum_comments_in_open_prs(date_from, date_to)
      @insightable
        .pull_requests
          .where(
            'pull_created_at > ? AND pull_created_at < ?',
            beginning_of_date('from', date_from),
            date_to.zero? ? DateTime.now : beginning_of_date('to', date_to)
          )
          .hashable_pluck(:entity_id, :pull_requests_comments_count)
          .each_with_object({}) { |element, acc|
            acc[element[:entity_id]] ||= []
            acc[element[:entity_id]].push(element[:pull_requests_comments_count])
          }
    end

    def premium
      @insightable.premium?
    end

    def configuration
      @configuration ||= @insightable.configuration
    end

    def beginning_of_date(type, value)
      @beginning_of_date ||= {}

      @beginning_of_date.fetch("#{type},#{value}") do |key|
        @beginning_of_date[key] = value.days.ago.beginning_of_day
      end
    end
  end
end
