# frozen_string_literal: true

module Import
  module Fetchers
    module Github
      class PullRequests
        prepend ApplicationService
        include Import::Concerns::Accessable

        PER_PAGE = 100

        def initialize(repository:, fetch_client: GithubApi::Client, duration_days: Insight::FETCH_DAYS_PERIOD)
          @repository = repository
          @fetch_client = fetch_client.new(repository: repository)
          @started_at_limit = (DateTime.now - (duration_days.days * (repository.premium? ? 2 : 1))).beginning_of_day
          # @start_from_pull_number = repository.configuration.start_from_pull_number.to_i
          @result = []
        end

        def call
          page = 1
          loop do
            # default sorting is desc by created_at attribute
            # first comes newest PRs
            result = @fetch_client.pull_requests(params: { state: 'all', per_page: PER_PAGE, page: page })
            break if !result[:success] && mark_repository_as_unaccessable

            mark_repository_as_accessable unless @repository.accessable
            body = filter_result(result[:body])
            break if body.blank?

            @result.concat(body)
            break if body.size != PER_PAGE

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
