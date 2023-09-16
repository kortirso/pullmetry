# frozen_string_literal: true

class IdentityValidator < ApplicationValidator
  include Deps[contract: 'contracts.identity']
end
