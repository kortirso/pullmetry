# frozen_string_literal: true

class IgnoreValidator < ApplicationValidator
  include Deps[contract: 'contracts.ignore']
end
