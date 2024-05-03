# frozen_string_literal: true

module Insights
  module Generate
    class RepositoryService < Insights::GenerateService
      def call(insightable:)
        @insightable = insightable
        @insight_visibility = insightable.configuration.private
        @fetch_period = @insightable.find_fetch_period

        generate_specific_repository_insights
        super()
      end

      private

      def generate_specific_repository_insights
        ActiveRecord::Base.transaction do
          remove_old_repository_insights
          generate_previous_repository_insight
          # update actual insight information for current period
          insight = @insightable.repository_insights.actual.new
          insight.update!(repository_insight_attributes)
        end
      end

      def remove_old_repository_insights
        @insightable.repository_insights.actual.destroy_all
        @insightable.repository_insights.previous.where.not(previous_date: previous_insight_date).destroy_all
      end

      def generate_previous_repository_insight
        # update insight information for previous period
        return @previous_insight = nil if !premium || !configuration.insight_ratio

        # create previous insight for date only once
        @previous_insight = @insightable.repository_insights.find_by(previous_date: previous_insight_date)
        return if @previous_insight.present?

        # commento: repositories_insights.previous_date
        @previous_insight = @insightable.repository_insights.new(previous_date: previous_insight_date)
        @previous_insight.update!(repository_insight_attributes(true))
      end

      # rubocop: disable Style/OptionalBooleanParameter
      def repository_insight_attributes(previous=false)
        Repositories::Insight::DEFAULT_ATTRIBUTES.inject({}) do |acc, insight_field|
          value = find_repository_insight_field_value(insight_field, previous)
          field_value =
            Repositories::Insight::DECIMAL_ATTRIBUTES.include?(insight_field) ? value.to_f : value.to_i

          acc.merge({ insight_field => field_value })
        end
      end
      # rubocop: enable Style/OptionalBooleanParameter

      def find_repository_insight_field_value(insight_field, previous)
        return send(:"repository_#{insight_field}") unless previous

        send(:"repository_#{insight_field}", @fetch_period * 2, @fetch_period)
      end

      def repository_open_pull_requests_count(date_from=@fetch_period, date_to=0)
        @repository_open_pull_requests_count ||= {}

        @repository_open_pull_requests_count.fetch("#{date_from},#{date_to}") do |key|
          @repository_open_pull_requests_count[key] = open_pull_requests_count(date_from, date_to).values.sum
        end
      end

      def repository_commented_pull_requests_count(date_from=@fetch_period, date_to=0)
        @repository_commented_pull_requests_count ||= {}

        @repository_commented_pull_requests_count.fetch("#{date_from},#{date_to}") do |key|
          @repository_commented_pull_requests_count[key] = begin
            commented_pulls =
              PullRequests::Comment
                .where(pull_request_id: pull_requests_ids(date_from, date_to))
                .pluck(:pull_request_id)

            reviewed_pulls =
              PullRequests::Review
                .where(pull_request_id: pull_requests_ids(date_from, date_to))
                .pluck(:pull_request_id)

            PullRequest.where(id: commented_pulls + reviewed_pulls).count
          end
        end
      end

      def repository_reviewed_pull_requests_count(date_from=@fetch_period, date_to=0)
        @repository_reviewed_pull_requests_count ||= {}

        @repository_reviewed_pull_requests_count.fetch("#{date_from},#{date_to}") do |key|
          @repository_reviewed_pull_requests_count[key] =
            PullRequests::Review
              .where(pull_request_id: pull_requests_ids(date_from, date_to))
              .pluck(:pull_request_id)
              .uniq
              .size
        end
      end

      def repository_merged_pull_requests_count(date_from=@fetch_period, date_to=0)
        @repository_merged_pull_requests_count ||= {}

        @repository_merged_pull_requests_count.fetch("#{date_from},#{date_to}") do |key|
          @repository_merged_pull_requests_count[key] =
            PullRequest
              .merged
              .where(id: pull_requests_ids(date_from, date_to))
              .count
        end
      end

      def repository_average_comment_time(date_from=@fetch_period, date_to=0)
        @repository_average_comment_time ||= {}

        @repository_average_comment_time.fetch("#{date_from},#{date_to}") do |key|
          @repository_average_comment_time[key] = begin
            values =
              @average_comment_time_service
                .call(
                  insightable: @insightable,
                  pull_requests_ids: pull_requests_ids(date_from, date_to),
                  with_vacations: false
                )[:result]
                .values

            @find_average_service.call(
              values: values.flatten,
              type: @insightable.configuration.average_type,
              round_digits: 2
            )
          end
        end
      end

      def repository_average_review_time(date_from=@fetch_period, date_to=0)
        @repository_average_review_time ||= {}

        @repository_average_review_time.fetch("#{date_from},#{date_to}") do |key|
          @repository_average_review_time[key] = begin
            values =
              @average_review_time_service
                .call(
                  insightable: @insightable,
                  pull_requests_ids: pull_requests_ids(date_from, date_to),
                  with_vacations: false
                )[:result]
                .values.flatten
            @find_average_service.call(
              values: values,
              type: @insightable.configuration.average_type,
              round_digits: 2
            )
          end
        end
      end

      def repository_average_merge_time(date_from=@fetch_period, date_to=0)
        @repository_average_merge_time ||= {}

        @repository_average_merge_time.fetch("#{date_from},#{date_to}") do |key|
          @repository_average_merge_time[key] = begin
            values =
              @average_merge_time_service
                .call(insightable: @insightable, pull_requests_ids: pull_requests_ids(date_from, date_to))[:result]
                .values.flatten
            @find_average_service.call(
              values: values,
              type: @insightable.configuration.average_type,
              round_digits: 2
            )
          end
        end
      end

      def repository_comments_count(date_from=@fetch_period, date_to=0)
        @repository_comments_count ||= {}

        @repository_comments_count.fetch("#{date_from},#{date_to}") do |key|
          @repository_comments_count[key] = comments_count(date_from, date_to).values.sum
        end
      end

      def repository_average_comments_count(date_from=@fetch_period, date_to=0)
        @repository_average_comments_count ||= {}

        @repository_average_comments_count.fetch("#{date_from},#{date_to}") do |key|
          @repository_average_comments_count[key] =
            @find_average_service.call(
              values: pull_requests_stats(date_from, date_to).pluck(:pull_requests_comments_count),
              type: @insightable.configuration.average_type,
              round_digits: 2
            )
        end
      end

      def repository_changed_loc(date_from=@fetch_period, date_to=0)
        @repository_changed_loc ||= {}

        @repository_changed_loc.fetch("#{date_from},#{date_to}") do |key|
          @repository_changed_loc[key] = changed_loc(date_from, date_to).values.sum
        end
      end

      def repository_average_changed_loc(date_from=@fetch_period, date_to=0)
        @repository_average_changed_loc ||= {}

        @repository_average_changed_loc.fetch("#{date_from},#{date_to}") do |key|
          @repository_average_changed_loc[key] =
            @find_average_service.call(
              values: pull_requests_stats(date_from, date_to).pluck(:changed_loc),
              type: @insightable.configuration.average_type,
              round_digits: 2
            )
        end
      end

      def comments_count(date_from=@fetch_period, date_to=0)
        @comments_count ||= {}

        @comments_count.fetch("#{date_from},#{date_to}") do |key|
          @comments_count[key] =
            PullRequests::Comment
              .where(pull_request_id: pull_requests_ids(date_from, date_to))
              .group(:entity_id).count
        end
      end

      def reviews_count(date_from=@fetch_period, date_to=0)
        @reviews_count ||= {}

        @reviews_count.fetch("#{date_from},#{date_to}") do |key|
          @reviews_count[key] =
            PullRequests::Review
              .approved
              .accepted
              .where(pull_request_id: pull_requests_ids(date_from, date_to))
              .group(:entity_id).count
        end
      end

      def bad_reviews_count(date_from=@fetch_period, date_to=0)
        @bad_reviews_count ||= {}

        @bad_reviews_count.fetch("#{date_from},#{date_to}") do |key|
          @bad_reviews_count[key] =
            PullRequests::Review
              .approved
              .rejected
              .where(pull_request_id: pull_requests_ids(date_from, date_to))
              .group(:entity_id).count
        end
      end

      def required_reviews_count(date_from=@fetch_period, date_to=0)
        @required_reviews_count ||= {}

        @required_reviews_count.fetch("#{date_from},#{date_to}") do |key|
          @required_reviews_count[key] =
            PullRequests::Review
              .required
              .where(pull_request_id: pull_requests_ids(date_from, date_to))
              .group(:entity_id).count
        end
      end

      def open_pull_requests_count(date_from=@fetch_period, date_to=0)
        @open_pull_requests_count ||= {}

        @open_pull_requests_count.fetch("#{date_from},#{date_to}") do |key|
          @open_pull_requests_count[key] =
            PullRequest
              .where(id: pull_requests_ids(date_from, date_to))
              .group(:entity_id).count
        end
      end

      def changed_loc(date_from=@fetch_period, date_to=0)
        @changed_loc ||= {}

        @changed_loc.fetch("#{date_from},#{date_to}") do |key|
          @changed_loc[key] =
            pull_requests_stats(date_from, date_to)
              .each_with_object({}) do |element, acc|
                next if element[:changed_loc].nil?

                acc[element[:entity_id]] ||= 0
                acc[element[:entity_id]] += element[:changed_loc]
              end
        end
      end

      def reviewed_loc(date_from=@fetch_period, date_to=0)
        @reviewed_loc ||= {}

        @reviewed_loc.fetch("#{date_from},#{date_to}") do |key|
          @reviewed_loc[key] =
            PullRequests::Review
              .approved
              .accepted
              .where(pull_request_id: pull_requests_ids(date_from, date_to))
              .includes(:pull_request)
              .group_by(&:entity_id)
              .transform_values do |reviews|
                reviews.sum { |review| review.pull_request.changed_loc }
              end
        end
      end
    end
  end
end
