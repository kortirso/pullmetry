# frozen_string_literal: true

module Users
  class CreateValidator < ApplicationValidator
    def initialize(contract: Users::CreateContract)
      @contract = contract
    end
  end
end
