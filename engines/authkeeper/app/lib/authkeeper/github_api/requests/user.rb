# frozen_string_literal: true

module Authkeeper
  module GithubApi
    module Requests
      module User
        def user(access_token:)
          get(
            path: 'user',
            headers: headers(access_token)
          )
        end
      end
    end
  end
end
