# frozen_string_literal: true

module Authkeeper
  module GithubApi
    module Requests
      module UserEmails
        def user_emails(access_token:)
          get(
            path: 'user/emails',
            headers: headers(access_token)
          )
        end
      end
    end
  end
end
