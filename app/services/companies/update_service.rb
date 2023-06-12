# frozen_string_literal: true

module Companies
  class UpdateService
    def call(company:, params:)
      company.update!(params)
    end
  end
end
