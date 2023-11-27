# frozen_string_literal: true

module Import
  class IgnoreService
    def call(company:, data:)
      ignored_entities = company.ignores.pluck(:entity_value)
      data.reject { |payload| ignored_entities.include?(payload.dig(:author, :login)) }
    end
  end
end
