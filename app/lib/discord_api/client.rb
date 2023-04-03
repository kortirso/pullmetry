# frozen_string_literal: true

module DiscordApi
  class Client < HttpService::Client
    include Requests::SendMessage

    BASE_URL = 'https://discord.com'

    option :url, default: proc { BASE_URL }

    private

    def headers
      {
        'Content-type' => 'application/json'
      }
    end
  end
end
