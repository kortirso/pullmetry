# frozen_string_literal: true

module Companies
  class CreateValidator < ApplicationValidator
    include Deps[contract: 'contracts.companies.create']
  end
end
