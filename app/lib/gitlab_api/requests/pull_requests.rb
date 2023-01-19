# frozen_string_literal: true

module GitlabApi
  module Requests
    module PullRequests
      def pull_requests(params: {})
        fetch_data("/api/v4/projects/#{repository_id}/merge_requests", params)
      end
    end
  end
end
