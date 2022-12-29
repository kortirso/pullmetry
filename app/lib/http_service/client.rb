# frozen_string_literal: true

require 'dry/initializer'

module HttpService
  class Client
    extend Dry::Initializer[undefined: false]

    option :url
    option :connection, default: proc { build_connection }

    def get(path:, params: {})
      response = connection.get(path) do |request|
        params.each do |param, value|
          request.params[param] = value
        end
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
