# frozen_string_literal: true

module GoogleApi
  module Requests
    module User
      def user(access_token:)
        get(path: "oauth2/v3/userinfo?access_token=#{access_token}")
      end
    end
  end
end
