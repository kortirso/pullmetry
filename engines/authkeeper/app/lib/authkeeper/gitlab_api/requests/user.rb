# frozen_string_literal: true

module Authkeeper
  module GitlabApi
    module Requests
      module User
        def user(access_token:)
          get(
            path: 'api/v4/user',
            headers: headers(access_token)
          )
        end
      end
    end
  end
end
