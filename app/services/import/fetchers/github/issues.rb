# frozen_string_literal: true

module Import
  module Fetchers
    module Github
      class Issues
        include Deps[fetch_client: 'api.github.client']

        PER_PAGE = 100

        def call(repository:, result: [])
          started_at_limit = find_started_at(repository)
          request_params = find_default_request_params(repository)
          page = 1
          loop do
            # default sorting is desc by created_at attribute
            # first comes newest issues
            request_params[:params] = { state: 'all', per_page: PER_PAGE, page: page }
            fetch_result = fetch_client.issues(**request_params)
            break unless fetch_result[:success]

            body = filter_result(fetch_result[:body], started_at_limit)
            break if body.blank?

            result.concat(body)
            break if body.size != PER_PAGE

            page += 1
          end
          { result: result }
        end

        private

        def filter_result(body, started_at_limit)
          body.select do |element|
            # Issues endpoints may return both issues and pull requests in the response.
            # You can identify pull requests by the pull_request key
            next false if element['pull_request']
            next false if Date.strptime(element['created_at'], '%Y-%m-%d') < started_at_limit

            true
          end
        end

        def find_started_at(repository)
          fetch_period = repository.find_fetch_period
          fetch_period *= 2 if repository.configuration.insight_ratio
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
