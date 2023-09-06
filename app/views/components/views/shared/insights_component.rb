# frozen_string_literal: true

module Views
  module Shared
    class InsightsComponent < ApplicationViewComponent
      def initialize(insightable:)
        @insightable = insightable
        @access_token = insightable.access_token
        @insights = insightable.sorted_insights
        @premium = insightable.premium?
        @insight_ratio = @premium && insightable.configuration.insight_ratio

        @seconds_converter = Converters::SecondsToTextService.new

        super()
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
        result += insight_ratio_value(insight, attribute) if @insight_ratio && result != '-'
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

        ratio_value = insight["#{attribute}_ratio"].to_i
        time_attribute = Insight::TIME_ATTRIBUTES.include?(attribute.to_sym)
        change_type = @insightable.configuration.insight_ratio_type == 'change'

        value = multiple_value(ratio_value, time_attribute, change_type)
        value_for_rendering = time_attribute && change_type ? convert_seconds(value.abs) : value.abs

        " (<span class='#{span_class(ratio_value, time_attribute)}'>#{value_sign(value)}#{value_for_rendering}#{change_type ? '' : '%'}</span>)"
      end
      # rubocop: enable Layout/LineLength

      def span_class(ratio_value, time_attribute)
        return 'negative' if ratio_value.negative? && !time_attribute
        return 'negative' if !ratio_value.negative? && time_attribute

        'positive'
      end

      def multiple_value(ratio_value, time_attribute, change_type)
        return ratio_value * -1 if time_attribute && !change_type

        ratio_value
      end

      def value_sign(value)
        return '+' if value.positive?
        return '-' if value.negative?

        ''
      end
    end
  end
end
