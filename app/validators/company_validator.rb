# frozen_string_literal: true

class CompanyValidator < ApplicationValidator
  def initialize(contract: CompanyContract)
    @contract = contract
  end
end
