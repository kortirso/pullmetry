# frozen_string_literal: true

module Authkeeper
  module GitlabAuthApi
    class Client < HttpService::Client
      include Requests::FetchAccessToken

      BASE_URL = 'https://gitlab.com'

      option :url, default: proc { BASE_URL }
    end
  end
end
