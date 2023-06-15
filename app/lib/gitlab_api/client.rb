# frozen_string_literal: true

module GitlabApi
  class Client < HttpService::Client
    include Requests::User
    include Requests::PullRequests
    include Requests::PullRequestComments
    include Requests::PullRequestReviews

    BASE_URL = 'https://gitlab.com'

    option :url, default: proc { BASE_URL }
    option :repository, optional: true

    private

    def repository_id
      @repository.external_id
    end

    def repository_access_token
      @repository.fetch_access_token&.value
    end

    def fetch_data(path, params)
      get(path: path, params: params, headers: headers(repository_access_token))
    end

    def headers(access_token)
      {
        'Authorization' => "Bearer #{access_token}"
      }
    end
  end
end
