# frozen_string_literal: true

module TelegramApi
  class Client < HttpService::Client
    include Requests::Messages
    include Requests::Webhooks

    BASE_URL = 'https://api.telegram.org'

    option :url, default: proc { BASE_URL }

    private

    def headers
      {
        'Content-type' => 'application/json'
      }
    end
  end
end
