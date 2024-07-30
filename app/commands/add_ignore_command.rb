# frozen_string_literal: true

class AddIgnoreCommand < BaseCommand
  use_contract do
    params do
      required(:insightable).filled(type?: Company)
      required(:entity_value).filled(:string)
    end
  end

  private

  def do_persist(input)
    ignore = ActiveRecord::Base.transaction do
      remove_entities(input)
      Ignore.create!(input)
    end

    { result: ignore }
  rescue ActiveRecord::RecordNotUnique => _e
    { errors: ['Ignore already exists'] }
  end

  def remove_entities(input)
    Insight
      .joins(:entity)
      .where(insightable: input[:insightable], entities: { login: input[:entity_value] })
      .destroy_all

    Insight
      .joins(:entity)
      .where(insightable: input[:insightable].repositories, entities: { login: input[:entity_value] })
      .destroy_all
  end
end
