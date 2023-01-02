# frozen_string_literal: true

class AccessTokenValidator < ApplicationValidator
  def initialize(contract: AccessTokenContract)
    @contract = contract
  end
end
