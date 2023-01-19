# frozen_string_literal: true

module GitlabApi
  module Requests
    module PullRequestReviews
      def pull_request_reviews(pull_number:, params: {})
        fetch_data("/api/v4/projects/#{repository_id}/merge_requests/#{pull_number}/approvals", params)
      end
    end
  end
end
