# frozen_string_literal: true

module SlackHooksApi
  class Client < HttpService::Client
    include Requests::SendMessage

    BASE_URL = 'https://hooks.slack.com'

    option :url, default: proc { BASE_URL }

    private

    def headers
      {
        'Content-type' => 'application/json'
      }
    end
  end
end
