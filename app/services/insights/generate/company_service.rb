# frozen_string_literal: true

module Insights
  module Generate
    class CompanyService < Insights::GenerateService
      def call(insightable:)
        @insightable = insightable
        @insight_visibility = insightable.current_config.private
        @fetch_period = insightable.current_config.fetch_period

        super()
      end

      private

      def comments_count(date_from=@fetch_period, date_to=0)
        @comments_count ||= {}

        @comments_count.fetch("#{date_from},#{date_to}") do |key|
          @comments_count[key] = sum_insights_attribute(date_to, :comments_count)
        end
      end

      def conventional_comments_count(date_from=@fetch_period, date_to=0)
        @conventional_comments_count ||= {}

        @conventional_comments_count.fetch("#{date_from},#{date_to}") do |key|
          @conventional_comments_count[key] = sum_insights_attribute(date_to, :conventional_comments_count)
        end
      end

      def reviews_count(date_from=@fetch_period, date_to=0)
        @reviews_count ||= {}

        @reviews_count.fetch("#{date_from},#{date_to}") do |key|
          @reviews_count[key] = sum_insights_attribute(date_to, :reviews_count)
        end
      end

      def bad_reviews_count(date_from=@fetch_period, date_to=0)
        @bad_reviews_count ||= {}

        @bad_reviews_count.fetch("#{date_from},#{date_to}") do |key|
          @bad_reviews_count[key] = sum_insights_attribute(date_to, :bad_reviews_count)
        end
      end

      def required_reviews_count(date_from=@fetch_period, date_to=0)
        @required_reviews_count ||= {}

        @required_reviews_count.fetch("#{date_from},#{date_to}") do |key|
          @required_reviews_count[key] = sum_insights_attribute(date_to, :required_reviews_count)
        end
      end

      def open_pull_requests_count(date_from=@fetch_period, date_to=0)
        @open_pull_requests_count ||= {}

        @open_pull_requests_count.fetch("#{date_from},#{date_to}") do |key|
          @open_pull_requests_count[key] = sum_insights_attribute(date_to, :open_pull_requests_count)
        end
      end

      def changed_loc(date_from=@fetch_period, date_to=0)
        @changed_loc ||= {}

        @changed_loc.fetch("#{date_from},#{date_to}") do |key|
          @changed_loc[key] = sum_insights_attribute(date_to, :changed_loc)
        end
      end

      def reviewed_loc(date_from=@fetch_period, date_to=0)
        @reviewed_loc ||= {}

        @reviewed_loc.fetch("#{date_from},#{date_to}") do |key|
          @reviewed_loc[key] = sum_insights_attribute(date_to, :reviewed_loc)
        end
      end

      def time_since_last_open_pull_seconds(date_from=@fetch_period, date_to=0)
        @time_since_last_open_pull_seconds ||= {}

        @time_since_last_open_pull_seconds.fetch("#{date_from},#{date_to}") do |key|
          @time_since_last_open_pull_seconds[key] =
            insights_data(date_to)
              .each_with_object({}) do |element, acc|
                entity_id = element[:entity_id]
                time_since_last_open_pull_seconds = element[:time_since_last_open_pull_seconds]

                next if time_since_last_open_pull_seconds.nil?
                next acc[entity_id] = time_since_last_open_pull_seconds unless acc[entity_id]
                next if time_since_last_open_pull_seconds >= acc[entity_id]

                acc[entity_id] = time_since_last_open_pull_seconds
              end
        end
      end

      def sum_insights_attribute(date_to, attribute_name)
        insights_data(date_to)
          .each_with_object({}) do |element, acc|
            next if element[attribute_name].nil?

            acc[element[:entity_id]] ||= 0
            acc[element[:entity_id]] += element[attribute_name]
          end
      end

      def insights_data(date_to)
        @insights_data ||= {}

        @insights_data.fetch(date_to) do |key|
          @insights_data[key] = begin
            relation = date_to.zero? ? Insight.actual : Insight.previous
            relation
              .where(insightable: @insightable.repositories)
              .hashable_pluck(
                :entity_id,
                :comments_count,
                :conventional_comments_count,
                :reviews_count,
                :bad_reviews_count,
                :required_reviews_count,
                :open_pull_requests_count,
                :changed_loc,
                :reviewed_loc,
                :time_since_last_open_pull_seconds
              )
          end
        end
      end
    end
  end
end
