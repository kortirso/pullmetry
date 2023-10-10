# frozen_string_literal: true

module Import
  module Fetchers
    module Github
      class Reviews
        prepend ApplicationService
        include Import::Concerns::Accessable

        PER_PAGE = 50

        # rubocop: disable Metrics/AbcSize
        def call(pull_request:, fetch_client: Pullmetry::Container['api.github.client'])
          @result = []

          repository = pull_request.repository
          request_params = find_default_request_params(repository, pull_request.pull_number)
          page = 1
          loop do
            # default sorting is asc by id attribute
            # first comes oldest PRs
            request_params[:params] = { per_page: PER_PAGE, page: page }
            result = fetch_client.pull_request_reviews(**request_params)
            break if !result[:success] && mark_repository_as_unaccessable(repository)

            mark_repository_as_accessable(repository) unless repository.accessable
            body = result[:body]
            break if body.blank?

            @result.concat(body.select { |review| review['state'] == 'APPROVED' })
            break if body.size != PER_PAGE

            page += 1
          end
        end
        # rubocop: enable Metrics/AbcSize

        private

        def find_default_request_params(repository, pull_number)
          {
            repository_link: repository.link,
            access_token: repository.fetch_access_token&.value,
            pull_number: pull_number
          }
        end
      end
    end
  end
end
