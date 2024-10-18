# frozen_string_literal: true

module Import
  module Fetchers
    module Github
      class IssueComments
        include Deps[fetch_client: 'api.github.client']

        PER_PAGE = 100

        def call(issue:, result: [])
          repository = issue.repository
          request_params = find_default_request_params(repository, issue.issue_number)
          page = 1
          loop do
            # default sorting is asc by id attribute
            # first comes oldest PRs
            request_params[:params] = { per_page: PER_PAGE, page: page }
            fetch_result = fetch_client.issue_comments(**request_params)
            break unless fetch_result[:success]

            body = fetch_result[:body]
            break if body.blank?

            result.concat(body)
            break if body.size != PER_PAGE

            page += 1
          end
          { result: result }
        end

        private

        def find_default_request_params(repository, issue_number)
          {
            repository_link: repository.link,
            access_token: repository.fetch_access_token&.value,
            issue_number: issue_number
          }
        end
      end
    end
  end
end
