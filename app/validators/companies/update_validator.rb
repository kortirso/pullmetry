# frozen_string_literal: true

module Companies
  class UpdateValidator < ApplicationValidator
    def initialize(contract: Companies::UpdateContract)
      @contract = contract
    end
  end
end
