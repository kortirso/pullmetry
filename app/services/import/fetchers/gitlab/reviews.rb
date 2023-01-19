# frozen_string_literal: true

module Import
  module Fetchers
    module Gitlab
      class Reviews
        prepend ApplicationService
        include Concerns::Urlable

        def initialize(pull_request:, fetch_client: GitlabApi::Client)
          @fetch_client = fetch_client.new(url: base_url(pull_request.repository), repository: pull_request.repository)
          @pull_number = pull_request.pull_number
          @result = []
        end

        def call
          @result = @fetch_client.pull_request_reviews(pull_number: @pull_number)
        end
      end
    end
  end
end
