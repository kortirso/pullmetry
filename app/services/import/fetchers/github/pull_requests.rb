# frozen_string_literal: true

module Import
  module Fetchers
    module Github
      class PullRequests
        include Deps[fetch_client: 'api.github.client']
        include Import::Concerns::Accessable

        PER_PAGE = 100

        # rubocop: disable Metrics/AbcSize
        def call(repository:, result: [])
          started_at_limit = find_started_at(repository)
          request_params = find_default_request_params(repository)
          page = 1
          loop do
            # default sorting is desc by created_at attribute
            # first comes newest PRs
            request_params[:params] = { state: 'all', per_page: PER_PAGE, page: page }
            fetch_result = fetch_client.pull_requests(**request_params)
            break if !fetch_result[:success] && mark_repository_as_unaccessable(repository)

            mark_repository_as_accessable(repository) unless repository.accessable
            body = filter_result(fetch_result[:body], started_at_limit)
            break if body.blank?

            result.concat(body)
            break if body.size != PER_PAGE

            page += 1
          end
          { result: result }
        end
        # rubocop: enable Metrics/AbcSize

        private

        def filter_result(body, started_at_limit)
          body.select do |element|
            # TODO: add repository configuration
            # next false if element['number'] < @start_from_pull_number
            # TODO: in this place condition can be skipped if Company has unlimited PRs fetching
            next false if Date.strptime(element['created_at'], '%Y-%m-%d') < started_at_limit

            true
          end
        end

        def find_started_at(repository)
          config = repository.current_config
          fetch_period = config.insight_ratio ? (config.fetch_period * 2) : config.fetch_period
          (DateTime.now - fetch_period.days).beginning_of_day
        end

        def find_default_request_params(repository)
          {
            repository_link: repository.link,
            access_token: repository.fetch_access_token&.value
          }
        end
      end
    end
  end
end
