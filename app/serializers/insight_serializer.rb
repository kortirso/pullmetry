# frozen_string_literal: true

class InsightSerializer < PankoApplicationSerializer
  include Helpers::Insight

  attributes :id, :values, :entity

  def id = SecureRandom.hex

  def values
    context[:insight_fields].index_with do |insight_field|
      value = object[insight_field]
      {
        value: Insight::DECIMAL_ATTRIBUTES.include?(insight_field.to_sym) ? value.to_f : value,
        ratio_value: context[:ratio_enabled] ? compare_with_previous_period(object, insight_field, context) : nil
      }.compact
    end
  end

  def entity
    context[:no_entity] ? nil : (Rails.cache.read("entity_payload_#{object.entity_id}_v1") || Entity::EMPTY_PAYLOAD)
  end
end
