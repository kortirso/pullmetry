# frozen_string_literal: true

class AddEntityIgnoreCommand < BaseCommand
  use_contract do
    params do
      required(:insightable).filled(type?: Company)
      required(:entity_value).filled(:string)
    end
  end

  private

  def do_persist(input)
    ignore = ActiveRecord::Base.transaction do
      remove_insights_of_entity(input)
      Entity::Ignore.create!(input)
    end

    { result: ignore }
  rescue ActiveRecord::RecordNotUnique => _e
    { errors: ['Ignore already exists'] }
  end

  def remove_insights_of_entity(input)
    Insight
      .joins(:entity)
      .destroy_by(insightable: input[:insightable], entities: { login: input[:entity_value] })

    Insight
      .joins(:entity)
      .destroy_by(insightable: input[:insightable].repositories, entities: { login: input[:entity_value] })
  end
end
