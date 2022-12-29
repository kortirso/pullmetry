# frozen_string_literal: true

module GithubApi
  class Client < HttpService::Client
    include Requests::PullRequests

    BASE_URL = 'https://api.github.com'

    option :url, default: proc { BASE_URL }
  end
end
