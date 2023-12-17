# frozen_string_literal: true

module Excludes
  module Rules
    class CreateValidator < ApplicationValidator
      include Deps[contract: 'contracts.excludes.rule']
    end
  end
end
