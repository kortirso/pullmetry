# frozen_string_literal: true

module GithubApi
  class Client < HttpService::Client
    include Requests::User
    include Requests::UserEmails
    include Requests::PullRequests
    include Requests::PullRequestComments
    include Requests::PullRequestReviews
    include Requests::PullRequestFiles

    BASE_URL = 'https://api.github.com'

    option :url, default: proc { BASE_URL }
    option :repository, optional: true

    private

    def repository_path
      URI(@repository.link).path
    end

    def repository_access_token
      @repository.fetch_access_token&.value
    end

    def fetch_data(path, params)
      get(path: path, params: params, headers: headers(repository_access_token))
    end

    def headers(access_token)
      {
        'Accept' => 'application/vnd.github+json',
        'X-GitHub-Api-Version' => '2022-11-28',
        'Authorization' => "Bearer #{access_token}"
      }
    end
  end
end
