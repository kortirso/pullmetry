# frozen_string_literal: true

class RepositoryValidator < ApplicationValidator
  include Deps[contract: 'contracts.repository']
end
