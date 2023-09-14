# frozen_string_literal: true

module Insights
  module Generate
    class RepositoryService < Insights::GenerateService
      private

      def comments_count(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
        @comments_count ||= {}

        @comments_count.fetch("#{date_from},#{date_to}") do |key|
          @comments_count[key] =
            PullRequests::Comment
              .where(pull_request_id: pull_requests_ids(date_from, date_to))
              .group(:entity_id).count
        end
      end

      def reviews_count(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
        @reviews_count ||= {}

        @reviews_count.fetch("#{date_from},#{date_to}") do |key|
          @reviews_count[key] =
            PullRequests::Review
              .approved
              .where(pull_request_id: pull_requests_ids(date_from, date_to))
              .group(:entity_id).count
        end
      end

      def required_reviews_count(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
        @required_reviews_count ||= {}

        @required_reviews_count.fetch("#{date_from},#{date_to}") do |key|
          @required_reviews_count[key] =
            PullRequests::Review
              .required
              .where(pull_request_id: pull_requests_ids(date_from, date_to))
              .group(:entity_id).count
        end
      end

      def open_pull_requests_count(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
        @open_pull_requests_count ||= {}

        @open_pull_requests_count.fetch("#{date_from},#{date_to}") do |key|
          @open_pull_requests_count[key] =
            PullRequest
              .where(id: pull_requests_ids(date_from, date_to))
              .group(:entity_id).count
        end
      end

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

      def changed_loc(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
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

      def reviewed_loc(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
        @reviewed_loc ||= {}

        @reviewed_loc.fetch("#{date_from},#{date_to}") do |key|
          @reviewed_loc[key] =
            PullRequests::Review
              .approved
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
