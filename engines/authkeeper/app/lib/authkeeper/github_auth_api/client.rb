# frozen_string_literal: true

module Authkeeper
  module GithubAuthApi
    class Client < HttpService::Client
      include Requests::FetchAccessToken

      BASE_URL = 'https://github.com'

      option :url, default: proc { BASE_URL }
    end
  end
end
