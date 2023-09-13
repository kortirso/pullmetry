# frozen_string_literal: true

module AccessTokens
  class CreateForm
    prepend ApplicationService
    include Validateable

    def call(tokenable:, params:)
      return if validate_with(validator, params) && failure?

      ActiveRecord::Base.transaction do
        tokenable.access_token&.destroy
        @result = tokenable.create_access_token!(params)
      end
    end

    private

    def validator = AccessTokenValidator
  end
end
