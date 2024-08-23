# frozen_string_literal: true

module Authkeeper
  module GitlabApi
    class Client < HttpService::Client
      include Requests::User

      BASE_URL = 'https://gitlab.com'

      option :url, default: proc { BASE_URL }

      private

      def headers(access_token)
        {
          'Authorization' => "Bearer #{access_token}"
        }
      end
    end
  end
end
