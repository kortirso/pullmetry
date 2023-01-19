# frozen_string_literal: true

module GitlabApi
  module Requests
    module PullRequestComments
      def pull_request_comments(pull_number:, params: {})
        fetch_data("/api/v4/projects/#{repository_id}/merge_requests/#{pull_number}/notes", params)
      end
    end
  end
end
