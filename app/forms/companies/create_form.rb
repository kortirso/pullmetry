# frozen_string_literal: true

module Companies
  class CreateForm
    include Deps[validator: 'validators.companies.create']

    def call(user:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      { result: user.companies.create!(params) }
    end
  end
end
