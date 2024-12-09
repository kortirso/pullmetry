# frozen_string_literal: true

class InsightSerializer < ApplicationSerializer
  attributes :id, :values, :entity

  def values
    context[:insight_fields].index_with do |insight_field|
      {
        value: convert_value(object[insight_field], insight_field.to_sym),
        ratio_value: context[:ratio_enabled] ? compare_with_previous_period(insight_field) : nil
      }.compact
    end
  end

  def entity
    context[:no_entity] ? nil : (Rails.cache.read("entity_payload_#{object.entity_id}_v1") || Entity::EMPTY_PAYLOAD)
  end

  private

  def convert_value(value, insight_field)
    Insight::DECIMAL_ATTRIBUTES.include?(insight_field) ? value.to_f : value
  end

  def compare_with_previous_period(insight_field)
    previous_insight =
      if context[:previous_insights].is_a?(Array)
        context[:previous_insights].find { |previous_insight| previous_insight.entity_id == object.entity_id }
      else
        context[:previous_insights]
      end
    return change_value(previous_insight, insight_field) if context[:ratio_type] == 'change'

    ratio_value(previous_insight, insight_field)
  end

  def ratio_value(previous_insight, insight_field)
    return 0 if previous_insight.nil?

    previous_period = previous_insight[insight_field].to_f
    return 0 if previous_period.zero?

    ((object[insight_field].to_f - previous_period) * 100 / previous_period).to_i
  end

  def change_value(previous_insight, insight_field)
    method_name = ::Insight::DECIMAL_ATTRIBUTES.include?(insight_field) ? :to_f : :to_i
    return object[insight_field].send(method_name) if previous_insight.nil?

    object[insight_field].send(method_name) - previous_insight[insight_field].send(method_name)
  end
end
