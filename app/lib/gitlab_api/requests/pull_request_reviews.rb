# frozen_string_literal: true

module GitlabApi
  module Requests
    module PullRequestReviews
      def pull_request_reviews(external_id:, access_token:, pull_number:, params: {})
        get(
          path: "/api/v4/projects/#{external_id}/merge_requests/#{pull_number}/approvals",
          params: params,
          headers: headers(access_token)
        )
      end
    end
  end
end
