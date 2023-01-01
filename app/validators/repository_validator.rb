# frozen_string_literal: true

class RepositoryValidator < ApplicationValidator
  def initialize(contract: RepositoryContract)
    @contract = contract
  end
end
