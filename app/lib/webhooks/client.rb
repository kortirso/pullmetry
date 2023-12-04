# frozen_string_literal: true

module Webhooks
  class Client < HttpService::Client
    include Requests::SendMessage

    private

    def headers
      {
        'Content-type' => 'application/json'
      }
    end
  end
end
