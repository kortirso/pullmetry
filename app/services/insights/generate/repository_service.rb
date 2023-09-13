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
    end
  end
end
