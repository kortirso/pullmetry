# frozen_string_literal: true

module GitlabApi
  module Requests
    module PullRequests
      def pull_requests(external_id:, access_token:, params: {})
        get(
          path: "/api/v4/projects/#{external_id}/merge_requests",
          params: params,
          headers: headers(access_token)
        )
      end
    end
  end
end
