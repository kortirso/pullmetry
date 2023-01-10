# frozen_string_literal: true

require 'dry/initializer'

module HttpService
  class Client
    extend Dry::Initializer[undefined: false]

    option :url
    option :connection, default: proc { build_connection }

    def get(path:, params: nil, headers: nil)
      response = connection.get(path, params, headers)
      response.body if response.success?
    end

    def post(path:, body: {}, params: {}, headers: {})
      response = connection.post(path) do |request|
        params.each do |param, value|
          request.params[param] = value
        end
        headers.each do |header, value|
          request.headers[header] = value
        end
        request.body = body.to_json
      end
      response.body if response.success?
    end

    private

    def build_connection
      Faraday.new(@url) do |conn|
        conn.request :json
        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
