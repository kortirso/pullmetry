# frozen_string_literal: true

module Insights
  class GenerateService
    def initialize(
      average_comment_time_service: AverageTime::ForCommentService.new,
      average_review_time_service: AverageTime::ForReviewService.new,
      average_merge_time_service: AverageTime::ForMergeService.new,
      find_average_service: Pullmetry::Container['math.find_average']
    )
      @average_comment_time_service = average_comment_time_service
      @average_review_time_service = average_review_time_service
      @average_merge_time_service = average_merge_time_service
      @find_average_service = find_average_service
    end

    def call
      ActiveRecord::Base.transaction do
        remove_old_insights
        entity_ids.each do |entity_id|
          generate_previous_insight(entity_id)

          # update actual insight information for current period
          insight = @insightable.insights.actual.find_or_initialize_by(entity_id: entity_id)
          insight.update!(insight_attributes(entity_id).merge(hidden: @insight_visibility))
        end
      end
    end

    private

    def entity_ids
      @entity_ids ||= Entities::ForInsightableQuery.resolve(insightable: @insightable).pluck(:id)
    end

    def remove_old_insights
      @insightable.insights.where.not(entity_id: entity_ids).destroy_all
      @insightable.insights.previous.where.not(previous_date: previous_insight_date).destroy_all
    end

    def generate_previous_insight(entity_id)
      # update insight information for previous period
      return @previous_insight = nil if !premium || !configuration.insight_ratio

      # create previous insight for date only once per entity
      @previous_insight = @insightable.insights.find_by(entity_id: entity_id, previous_date: previous_insight_date)
      return if @previous_insight.present?

      # commento: insights.previous_date
      @previous_insight = @insightable.insights.new(entity_id: entity_id, previous_date: previous_insight_date)
      @previous_insight.update!(insight_attributes(entity_id, true))
    end

    # this method generates insight attributes based on available insight_fields
    # rubocop: disable Style/OptionalBooleanParameter
    def insight_attributes(entity_id, previous=false)
      insight_fields.inject({}) do |acc, insight_field|
        value = find_insight_field_value(insight_field, entity_id, previous)
        field_value = Insight::DECIMAL_ATTRIBUTES.include?(insight_field.to_sym) ? value.to_f : value.to_i

        acc.merge({ insight_field.to_sym => field_value })
      end
    end
    # rubocop: enable Style/OptionalBooleanParameter

    def find_insight_field_value(insight_field, entity_id, previous)
      return send(insight_field, @fetch_period * 2, @fetch_period)[entity_id] if previous

      send(insight_field)[entity_id]
    end

    # selecting insight attributes based on company configuration
    def insight_fields
      @insight_fields ||=
        if premium && configuration.insight_fields.present?
          @insightable.selected_insight_fields
        else
          Insight::DEFAULT_ATTRIBUTES
        end
    end

    # this method returns { entity_id => comments_count_by_entity }
    def comments_count(...) = raise NotImplementedError

    # this method returns { entity_id => reviews_count }
    def reviews_count(...) = raise NotImplementedError

    # this method returns { entity_id => bad_reviews_count }
    def bad_reviews_count(...) = raise NotImplementedError

    # this method returns { entity_id => required_reviews_count }
    def required_reviews_count(...) = raise NotImplementedError

    # this method returns { entity_id => review_involving }
    def review_involving(...) = raise NotImplementedError

    # this method returns { entity_id => open_pull_requests_count }
    def open_pull_requests_count(...) = raise NotImplementedError

    # this method returns { entity_id => changed LOC in entity PRs }
    def changed_loc(...) = raise NotImplementedError

    # this method returns { entity_id => changed LOC in reviewed PRs }
    def reviewed_loc(...) = raise NotImplementedError

    def pulls_with_user_comments(date_from=@fetch_period, date_to=0)
      @pulls_with_user_comments ||= {}

      @pulls_with_user_comments.fetch("#{date_from},#{date_to}") do |key|
        @pulls_with_user_comments[key] =
          PullRequest
            .where(id: pull_requests_ids(date_from, date_to))
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
    def average_review_seconds(date_from=@fetch_period, date_to=0)
      @average_review_seconds ||= {}

      @average_review_seconds.fetch("#{date_from},#{date_to}") do |key|
        @average_review_seconds[key] =
          @average_review_time_service
            .call(insightable: @insightable, pull_requests_ids: pull_requests_ids(date_from, date_to))[:result]
            .transform_values! do |value|
              @find_average_service.call(values: value, type: @insightable.configuration.average_type)
            end
      end
    end

    # this method returns { entity_id => average_merge_seconds }
    def average_merge_seconds(date_from=@fetch_period, date_to=0)
      @average_merge_seconds ||= {}

      @average_merge_seconds.fetch("#{date_from},#{date_to}") do |key|
        @average_merge_seconds[key] =
          @average_merge_time_service
            .call(insightable: @insightable, pull_requests_ids: pull_requests_ids(date_from, date_to))[:result]
            .transform_values! do |value|
              @find_average_service.call(values: value, type: @insightable.configuration.average_type)
            end
      end
    end

    def average_open_pr_comments(date_from=@fetch_period, date_to=0)
      @average_open_pr_comments ||= {}

      @average_open_pr_comments.fetch("#{date_from},#{date_to}") do |key|
        @average_open_pr_comments[key] =
          comments_in_open_prs(date_from, date_to).transform_values { |value|
            @find_average_service.call(values: value, type: @insightable.configuration.average_type, round_digits: 2)
          }
      end
    end

    # this method returns { entity_id => average changed LOC in entity PRs }
    def average_changed_loc(date_from=@fetch_period, date_to=0)
      @average_changed_loc ||= {}

      @average_changed_loc.fetch("#{date_from},#{date_to}") do |key|
        @average_changed_loc[key] =
          changed_loc_in_open_prs(date_from, date_to).transform_values { |value|
            @find_average_service.call(values: value, type: @insightable.configuration.average_type, round_digits: 2)
          }
      end
    end

    # this method returns { entity_id => average changed LOC in reviewed PRs }
    def average_reviewed_loc(date_from=@fetch_period, date_to=0)
      @average_reviewed_loc ||= {}

      @average_reviewed_loc.fetch("#{date_from},#{date_to}") do |key|
        @average_reviewed_loc[key] =
          reviewed_loc_in_open_prs(date_from, date_to).transform_values { |value|
            @find_average_service.call(values: value, type: @insightable.configuration.average_type, round_digits: 2)
          }
      end
    end

    def reviewed_loc_in_open_prs(date_from=@fetch_period, date_to=0)
      @reviewed_loc_in_open_prs ||= {}

      @reviewed_loc_in_open_prs.fetch("#{date_from},#{date_to}") do |key|
        @reviewed_loc_in_open_prs[key] =
          PullRequests::Review
            .approved
            .where(pull_request_id: pull_requests_ids(date_from, date_to))
            .group_by(&:entity_id)
            .transform_values do |reviews|
              reviews.map { |review| review.pull_request.changed_loc }
            end
      end
    end

    def changed_loc_in_open_prs(date_from, date_to)
      pull_requests_stats(date_from, date_to)
        .each_with_object({}) { |element, acc|
          acc[element[:entity_id]] ||= []
          acc[element[:entity_id]].push(element[:changed_loc])
        }
    end

    def comments_in_open_prs(date_from, date_to)
      pull_requests_stats(date_from, date_to)
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

    def previous_insight_date
      @previous_insight_date ||= (@fetch_period * 2).days.ago.to_date.to_s
    end

    def beginning_of_date(type, value)
      @beginning_of_date ||= {}

      @beginning_of_date.fetch("#{type},#{value}") do |key|
        @beginning_of_date[key] = value.days.ago.beginning_of_day
      end
    end

    def pull_requests_ids(date_from, date_to)
      @pull_requests_ids ||= {}

      @pull_requests_ids.fetch("#{date_from},#{date_to}") do |key|
        @pull_requests_ids[key] =
          @insightable
            .pull_requests
            .where(
              'pull_created_at > ? AND pull_created_at < ?',
              beginning_of_date('from', date_from),
              date_to.zero? ? DateTime.now : beginning_of_date('to', date_to)
            )
            .ids
      end
    end

    def pull_requests_stats(date_from, date_to)
      @pull_requests_stats ||= {}

      @pull_requests_stats.fetch("#{date_from},#{date_to}") do |key|
        @pull_requests_stats[key] =
          PullRequest
            .where(id: pull_requests_ids(date_from, date_to))
            .hashable_pluck(:entity_id, :pull_requests_comments_count, :changed_loc)
      end
    end
  end
end
