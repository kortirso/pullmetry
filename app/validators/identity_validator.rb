# frozen_string_literal: true

class IdentityValidator < ApplicationValidator
  def initialize(contract: IdentityContract)
    @contract = contract
  end
end
