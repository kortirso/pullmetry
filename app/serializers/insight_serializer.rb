# frozen_string_literal: true

class InsightSerializer < ApplicationSerializer
  extend Helpers::Insight

  attribute :values do |object, params|
    params[:insight_fields].index_with do |insight_field|
      value = object[insight_field]
      {
        value: Insight::DECIMAL_ATTRIBUTES.include?(insight_field.to_sym) ? value.to_f : value,
        ratio_value: params[:ratio_enabled] ? compare_with_previous_period(object, insight_field, params) : nil
      }
    end
  end

  attribute :ratio_type do |_, params|
    params[:ratio_enabled] ? params[:ratio_type] : nil
  end

  attribute :entity do |object, params|
    params[:no_entity] ? nil : (Rails.cache.read("entity_payload_#{object.entity_id}_v1") || Entity::EMPTY_PAYLOAD)
  end
end
