# frozen_string_literal: true

module Subscribers
  class CreateValidator < ApplicationValidator
    include Deps[contract: 'contracts.subscribers.create']
  end
end
