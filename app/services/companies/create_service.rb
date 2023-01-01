# frozen_string_literal: true

module Companies
  class CreateService
    prepend ApplicationService

    def initialize(company_validator: CompanyValidator)
      @company_validator = company_validator
    end

    def call(user:, params:)
      return if validate_with(@company_validator, params) && failure?

      @result = user.companies.create!(params)
    end
  end
end
