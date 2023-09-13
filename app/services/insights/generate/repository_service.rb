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
              .joins(:pull_request)
              .where(pull_requests: { repository_id: @insightable.id })
              .where(
                'pull_requests.pull_created_at > ? AND pull_requests.pull_created_at < ?',
                beginning_of_date('from', date_from),
                date_to.zero? ? DateTime.now : beginning_of_date('to', date_to)
              )
              .group(:entity_id).count
        end
      end

      def reviews_count(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
        @reviews_count ||= {}

        @reviews_count.fetch("#{date_from},#{date_to}") do |key|
          @reviews_count[key] =
            PullRequests::Review
              .approved
              .joins(:pull_request)
              .where(pull_requests: { repository_id: @insightable.id })
              .where(
                'pull_requests.pull_created_at > ? AND pull_requests.pull_created_at < ?',
                beginning_of_date('from', date_from),
                date_to.zero? ? DateTime.now : beginning_of_date('to', date_to)
              )
              .group(:entity_id).count
        end
      end

      def required_reviews_count(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
        @required_reviews_count ||= {}

        @required_reviews_count.fetch("#{date_from},#{date_to}") do |key|
          @required_reviews_count[key] =
            PullRequests::Review
              .required
              .joins(:pull_request)
              .where(pull_requests: { repository_id: @insightable.id })
              .where(
                'pull_requests.pull_created_at > ? AND pull_requests.pull_created_at < ?',
                beginning_of_date('from', date_from),
                date_to.zero? ? DateTime.now : beginning_of_date('to', date_to)
              )
              .group(:entity_id).count
        end
      end

      def open_pull_requests_count(date_from=Insight::FETCH_DAYS_PERIOD, date_to=0)
        @open_pull_requests_count ||= {}

        @open_pull_requests_count.fetch("#{date_from},#{date_to}") do |key|
          @open_pull_requests_count[key] =
            @insightable
              .pull_requests
              .where(
                'pull_created_at > ? AND pull_created_at < ?',
                beginning_of_date('from', date_from),
                date_to.zero? ? DateTime.now : beginning_of_date('to', date_to)
              )
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
    end
  end
end
