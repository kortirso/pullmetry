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
      @entity_ids ||= Entities::ForInsightableQuery.resolve(insightable: @insightable).pluck(:id)
    end

    def remove_old_insights
      @insightable.insights.where.not(entity_id: entity_ids).destroy_all
    end

    # this method generates insight attributes based on available insight_fields
    def insight_attributes(entity_id)
      insight_fields.inject({}) do |acc, insight_field|
        field_value =
          if insight_field.ends_with?('ratio')
            method_name = configuration.insight_ratio_type == 'ratio' ? :ratio : :change
            send(method_name, insight_field[0..-7], entity_id)
          else
            value = send(insight_field)[entity_id]
            Insight::DECIMAL_ATTRIBUTES.include?(insight_field.to_sym) ? value.to_f : value.to_i
          end

        acc.merge({ insight_field.to_sym => field_value })
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
      previous_period =
        send(insight_field, Insight::DOUBLE_FETCH_DAYS_PERIOD, Insight::FETCH_DAYS_PERIOD)[entity_id].to_i
      return 0 if previous_period.zero?

      (send(insight_field)[entity_id].to_i - previous_period) * 100 / previous_period
    end

    def change(insight_field, entity_id)
      previous_period = send(insight_field, Insight::DOUBLE_FETCH_DAYS_PERIOD, Insight::FETCH_DAYS_PERIOD)[entity_id]
      send(insight_field)[entity_id].to_i - previous_period.to_i
    end

    # this method returns { entity_id => comments_count }
    def comments_count(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
      @comments_count ||= {}

      @comments_count.fetch("#{date_from},#{date_to}") do |key|
        @comments_count[key] =
          @insightable
            .pull_requests_comments
            .joins(:pull_request)
            .where(
              'pull_requests.pull_created_at > ? AND pull_requests.pull_created_at < ?',
              date_from.days.ago,
              date_to.days.ago
            )
            .group(:entity_id).count
      end
    end

    # this method returns { entity_id => reviews_count }
    def reviews_count(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
      @reviews_count ||= {}

      @reviews_count.fetch("#{date_from},#{date_to}") do |key|
        @reviews_count[key] =
          @insightable
            .pull_requests_reviews
            .approved
            .joins(:pull_request)
            .where(
              'pull_requests.pull_created_at > ? AND pull_requests.pull_created_at < ?',
              date_from.days.ago,
              date_to.days.ago
            )
            .group(:entity_id).count
      end
    end

    # this method returns { entity_id => required_reviews_count }
    def required_reviews_count(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
      @required_reviews_count ||= {}

      @required_reviews_count.fetch("#{date_from},#{date_to}") do |key|
        @required_reviews_count[key] =
          @insightable
            .pull_requests_reviews
            .required
            .joins(:pull_request)
            .where(
              'pull_requests.pull_created_at > ? AND pull_requests.pull_created_at < ?',
              date_from.days.ago,
              date_to.days.ago
            )
            .group(:entity_id).count
      end
    end

    # this method returns { entity_id => review_involving }
    # rubocop: disable Metrics/AbcSize
    def review_involving(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
      @review_involving ||= {}

      @review_involving.fetch("#{date_from},#{date_to}") do |key|
        @review_involving[key] =
          entity_ids.each_with_object({}) do |entity_id, acc|
            other_user_pulls = open_pull_requests_count(date_from, date_to).except(entity_id).values.sum
            return 0 if other_user_pulls.zero?

            commented_pulls = pulls_with_user_comments(date_from, date_to)[entity_id].to_i
            reviewed_pulls = reviews_count(date_from, date_to)[entity_id].to_i
            acc[entity_id] = 100 * (commented_pulls + reviewed_pulls) / other_user_pulls
          end
      end
    end
    # rubocop: enable Metrics/AbcSize

    def pulls_with_user_comments(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
      @pulls_with_user_comments ||= {}

      @pulls_with_user_comments.fetch("#{date_from},#{date_to}") do |key|
        @pulls_with_user_comments[key] =
          @insightable
            .pull_requests
            .where(
              'pull_created_at > ? AND pull_created_at < ?',
              date_from.days.ago,
              date_to.days.ago
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

    # this method returns { entity_id => open_pull_requests_count }
    def open_pull_requests_count(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
      @open_pull_requests_count ||= {}

      @open_pull_requests_count.fetch("#{date_from},#{date_to}") do |key|
        @open_pull_requests_count[key] =
          @insightable
            .pull_requests
            .where(
              'pull_created_at > ? AND pull_created_at < ?',
              date_from.days.ago,
              date_to.days.ago
            )
            .group(:entity_id).count
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
            date_from.days.ago,
            date_to.days.ago
          )
          .each_with_object({}) { |pull_request, acc|
            entity_id = pull_request.entity_id
            next if entity_id.nil?

            comments_count = pull_request.pull_requests_comments_count
            acc[entity_id] ? acc[entity_id].push(comments_count) : (acc[entity_id] = [comments_count])
          }
    end

    def premium
      @insightable.premium?
    end

    def configuration
      @configuration ||= @insightable.configuration
    end
  end
end
