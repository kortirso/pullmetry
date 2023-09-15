# frozen_string_literal: true

module Views
  module Shared
    class InsightsComponent < ApplicationViewComponent
      def initialize(insightable:)
        @insightable = insightable
        @access_token = insightable.access_token
        @premium = insightable.premium?
        @insight_ratio = @premium && insightable.configuration.insight_ratio

        @seconds_converter = Converters::SecondsToTextService.new

        super()
      end

      def visible_insights
        @visible_insights ||=
          Insights::VisibleQuery
            .new(relation: @insightable.insights)
            .resolve(insightable: @insightable)
            .load
      end

      def actual_insights
        @actual_insights ||= visible_insights.select(&:actual?)
      end

      def previous_insights
        @previous_insights ||= visible_insights.reject(&:actual?)
      end

      def insight_fields
        @insight_fields ||=
          if @premium && @insightable.configuration.insight_fields.present?
            @insightable.selected_insight_fields
          else
            Insight::DEFAULT_ATTRIBUTES
          end
      end

      # rubocop: disable Rails/OutputSafety
      def render_insight_field(insight, attribute)
        result = convert_insight_field(insight, attribute.to_sym).to_s
        result += insight_ratio_value(insight, attribute.to_sym) if @insight_ratio && result != '-'
        result.html_safe
      end
      # rubocop: enable Rails/OutputSafety

      private

      def convert_insight_field(insight, insight_field)
        return convert_seconds(insight[insight_field]) if Insight::TIME_ATTRIBUTES.include?(insight_field)
        return insight[insight_field].to_f if Insight::DECIMAL_ATTRIBUTES.include?(insight_field)
        return "#{insight[insight_field].to_i}%" if Insight::PERCENTILE_ATTRIBUTES.include?(insight_field)

        insight[insight_field].to_i
      end

      def convert_seconds(value)
        @seconds_converter.call(value: value)
      end

      # rubocop: disable Layout/LineLength
      def insight_ratio_value(insight, attribute)
        return '' if insight[attribute].nil?

        time_attribute = Insight::TIME_ATTRIBUTES.include?(attribute)
        reverse_attribute = Insight::REVERSE_ORDER_ATTRIBUTES.include?(attribute)
        change_type = @insightable.configuration.insight_ratio_type == 'change'
        ratio_value = change_type ? change_value(insight, attribute) : ratio_value(insight, attribute)

        value = multiple_value(ratio_value, reverse_attribute, change_type)
        value_for_rendering = time_attribute && change_type ? convert_seconds(value.abs) : value.abs

        "<sup class='#{span_class(ratio_value, reverse_attribute)}'>#{value_sign(value, reverse_attribute)}#{value_for_rendering}#{change_type ? '' : '%'}</sup>"
      end
      # rubocop: enable Layout/LineLength

      def span_class(ratio_value, reverse_attribute)
        return 'negative' if ratio_value.negative? && !reverse_attribute
        return 'negative' if !ratio_value.negative? && reverse_attribute

        'positive'
      end

      def multiple_value(ratio_value, reverse_attribute, change_type)
        return ratio_value * -1 if reverse_attribute && !change_type

        ratio_value
      end

      def value_sign(value, reverse_attribute)
        return '' if value.zero?
        return '+' if value.positive? && !reverse_attribute || value.negative? && reverse_attribute

        '-'
      end

      def ratio_value(insight, attribute)
        previous_insight = previous_insights.find { |previous_insight| previous_insight.entity_id == insight.entity_id }
        return 0 if previous_insight.nil?

        previous_period = previous_insight[attribute].to_f
        return 0 if previous_period.zero?

        ((insight[attribute].to_f - previous_period) * 100 / previous_period).to_i
      end

      def change_value(insight, insight_field)
        method_name = insight_field == 'average_open_pr_comments' ? :to_f : :to_i
        previous_insight = previous_insights.find { |previous_insight| previous_insight.entity_id == insight.entity_id }
        return insight[attribute].send(method_name) if previous_insight.nil?

        insight[attribute].send(method_name) - previous_insight[insight_field].send(method_name)
      end
    end
  end
end
