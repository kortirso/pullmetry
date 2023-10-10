# frozen_string_literal: true

module Import
  module Fetchers
    module Gitlab
      class PullRequests
        prepend ApplicationService
        include Concerns::Urlable
        include Import::Concerns::Accessable

        PER_PAGE = 25

        # rubocop: disable Metrics/AbcSize
        def call(repository:, fetch_client: GitlabApi::Client)
          @started_at_limit = (DateTime.now - Insight::FETCH_DAYS_PERIOD.days).beginning_of_day
          @result = []

          fetch_client = fetch_client.new(url: base_url(repository))
          request_params = find_default_request_params(repository)
          page = 1
          loop do
            # default sorting is desc by created_at attribute
            # first comes newest PRs
            request_params[:params] = { per_page: PER_PAGE, page: page }
            result = fetch_client.pull_requests(**request_params)
            break if !result[:success] && mark_repository_as_unaccessable(repository)

            mark_repository_as_accessable(repository) unless repository.accessable
            body = filter_result(result[:body])
            break if body.blank?

            @result.concat(body)
            page += 1
          end
        end
        # rubocop: enable Metrics/AbcSize

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

        def find_default_request_params(repository)
          {
            external_id: repository.external_id,
            access_token: repository.fetch_access_token&.value
          }
        end
      end
    end
  end
end
