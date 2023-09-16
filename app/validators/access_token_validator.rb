# frozen_string_literal: true

class AccessTokenValidator < ApplicationValidator
  include Deps[contract: 'contracts.access_token']
end
