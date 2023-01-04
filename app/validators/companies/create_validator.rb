# frozen_string_literal: true

module Companies
  class CreateValidator < ApplicationValidator
    def initialize(contract: Companies::CreateContract)
      @contract = contract
    end
  end
end
