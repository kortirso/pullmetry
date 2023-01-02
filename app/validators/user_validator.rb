# frozen_string_literal: true

class UserValidator < ApplicationValidator
  def initialize(contract: UserContract)
    @contract = contract
  end
end
