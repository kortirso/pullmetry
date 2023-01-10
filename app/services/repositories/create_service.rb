# frozen_string_literal: true

module Repositories
  class CreateService
    prepend ApplicationService
    include Validateable

    def initialize(repository_validator: RepositoryValidator)
      @repository_validator = repository_validator
    end

    def call(company:, params:)
      return if validate_with(@repository_validator, params) && failure?

      @result = company.repositories.create!(params)
    end
  end
end
