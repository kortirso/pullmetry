# frozen_string_literal: true

module Authkeeper
  module GithubApi
    class Client < HttpService::Client
      include Requests::User
      include Requests::UserEmails

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
end
