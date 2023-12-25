# frozen_string_literal: true

module Configurable
  extend ActiveSupport::Concern

  included do
    attribute :configuration, JsonbColumns::Configuration.to_type
  end

  def with_work_time?
    configuration.work_start_time.present? && configuration.work_end_time.present?
  end

  def selected_insight_fields
    configuration.insight_fields.attributes.filter_map { |key, value| value ? key : nil }
  end

  def find_fetch_period
    return Insight::FETCH_DAYS_PERIOD if configuration.fetch_period.blank?
    return configuration.fetch_period if premium?

    [configuration.fetch_period, Insight::FETCH_DAYS_PERIOD].min
  end
end
