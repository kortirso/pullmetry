# frozen_string_literal: true

module Ignores
  class CreateForm
    include Deps[validator: 'validators.ignore']

    def call(company:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      result = ActiveRecord::Base.transaction do
        remove_entities(company, params[:entity_value])
        company.ignores.create!(params)
      end

      { result: result }
    end

    private

    def remove_entities(company, entity_value)
      Insight
        .joins(:entity)
        .where(insightable: company, entities: { login: entity_value })
        .destroy_all

      Insight
        .joins(:entity)
        .where(insightable: company.repositories, entities: { login: entity_value })
        .destroy_all
    end
  end
end
