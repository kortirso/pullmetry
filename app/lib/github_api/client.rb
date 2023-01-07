# frozen_string_literal: true

module GithubApi
  class Client < HttpService::Client
    include Requests::PullRequests
    include Requests::PullRequestComments
    include Requests::PullRequestReviews
    include Requests::PullRequestReviewComments

    BASE_URL = 'https://api.github.com'

    option :url, default: proc { BASE_URL }
    option :repository

    private

    def repository_path
      URI(@repository.link).path
    end

    def access_token
      @repository.fetch_access_token&.value
    end

    def fetch_data(path, params)
      get(path: path, params: params, headers: headers)
    end

    def headers
      {
        'Accept' => 'application/vnd.github+json',
        'Authorization' => "Bearer #{access_token}",
        'X-GitHub-Api-Version' => '2022-11-28'
      }
    end
  end
end
