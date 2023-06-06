# frozen_string_literal: true

module Import
  module Fetchers
    module Gitlab
      class PullRequests
        prepend ApplicationService
        include Concerns::Urlable
        include Import::Concerns::Accessable

        PER_PAGE = 25

        def initialize(repository:, fetch_client: GitlabApi::Client, duration_days: Insight::FETCH_DAYS_PERIOD)
          @repository = repository
          @fetch_client = fetch_client.new(url: base_url(repository), repository: repository)
          @started_at_limit = (DateTime.now - duration_days.days).beginning_of_day
          @result = []
        end

        def call
          page = 1
          loop do
            # default sorting is desc by created_at attribute
            # first comes newest PRs
            result = @fetch_client.pull_requests(params: { per_page: PER_PAGE, page: page })
            break if !result[:success] && mark_repository_as_unaccessable

            body = filter_result(result[:body])
            break if body.blank?

            @result.concat(body)
            page += 1
          end
        end

        private

        def filter_result(body)
          body.select do |element|
            # TODO: add repository configuration
            # next false if element['number'] < @start_from_pull_number
            # TODO: in this place condition can be skipped if Company has unlimited PRs fetching
            next false if Date.strptime(element['created_at'], '%Y-%m-%d') < @started_at_limit

            true
          end
        end
      end
    end
  end
end
