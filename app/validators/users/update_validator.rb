# frozen_string_literal: true

module Users
  class UpdateValidator < ApplicationValidator
    def initialize(contract: Users::UpdateContract)
      @contract = contract
    end
  end
end
