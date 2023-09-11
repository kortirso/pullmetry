# frozen_string_literal: true

module Companies
  class CreateForm
    prepend ApplicationService
    include Validateable

    def call(user:, params:)
      return if validate_with(validator, params) && failure?

      @result = user.companies.create!(params)
    end

    private

    def validator = Companies::CreateValidator
  end
end
