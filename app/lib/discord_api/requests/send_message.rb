# frozen_string_literal: true

module DiscordApi
  module Requests
    module SendMessage
      def send_message(path:, body:)
        post(
          path: path,
          body: body,
          headers: headers
        )
      end
    end
  end
end
