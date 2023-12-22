# frozen_string_literal: true

module Helpers
  module Insight
    def compare_with_previous_period(object, insight_field, params)
      previous_insight =
        if params[:previous_insights].is_a?(Array)
          params[:previous_insights].find { |previous_insight| previous_insight.entity_id == object.entity_id }
        else
          params[:previous_insights]
        end
      return change_value(object, previous_insight, insight_field) if params[:ratio_type] == 'change'

      ratio_value(object, previous_insight, insight_field)
    end

    def ratio_value(insight, previous_insight, attribute)
      return 0 if previous_insight.nil?

      previous_period = previous_insight[attribute].to_f
      return 0 if previous_period.zero?

      ((insight[attribute].to_f - previous_period) * 100 / previous_period).to_i
    end

    def change_value(insight, previous_insight, insight_field)
      method_name = ::Insight::DECIMAL_ATTRIBUTES.include?(insight_field) ? :to_f : :to_i
      return insight[attribute].send(method_name) if previous_insight.nil?

      insight[attribute].send(method_name) - previous_insight[insight_field].send(method_name)
    end
  end
end
