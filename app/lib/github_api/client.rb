# frozen_string_literal: true

module GithubApi
  class Client < HttpService::Client
    include Requests::PullRequests
    include Requests::PullRequestComments
    include Requests::PullRequestReviews
    include Requests::PullRequestFiles
    include Requests::Issues
    include Requests::IssueComments

    BASE_URL = 'https://api.github.com'

    option :url, default: proc { BASE_URL }

    private

    def headers(access_token)
      {
        'Accept' => 'application/vnd.github+json',
        'X-GitHub-Api-Version' => '2022-11-28',
        'Authorization' => "Bearer #{access_token}"
      }
    end
  end
end
