# frozen_string_literal: true

module Views
  module Shared
    class InsightsComponent < ApplicationViewComponent
      def initialize(insightable:)
        @insightable = insightable
        @access_token = insightable.access_token
        @insights = @insightable.sorted_insights

        super()
      end

      def convert_seconds(value)
        Converters::SecondsToTextService.new.call(value: value)
      end

      # rubocop: disable Layout/LineLength, Rails/OutputSafety
      def insight_ratio_value(insight, attribute)
        ratio_field_name = "#{attribute}_ratio"
        ratio_value = insight[ratio_field_name].to_i
        # for time attributes less value is better
        ratio_value *= -1 if Insight::TIME_ATTRIBUTES.include?(attribute)

        "(<span class='#{ratio_value.negative? ? 'negative' : 'positive'}'>#{ratio_value.positive? ? '+' : ''}#{ratio_value}%</span>)".html_safe
      end
      # rubocop: enable Layout/LineLength, Rails/OutputSafety

      def insight_fields
        @insight_fields ||=
          if premium && @insightable.configuration.insight_fields.present?
            @insightable.selected_insight_fields
          else
            Insight::DEFAULT_ATTRIBUTES
          end
      end

      def convert_insight_field(insight, insight_field)
        return convert_seconds(insight[insight_field]) if Insight::TIME_ATTRIBUTES.include?(insight_field)
        return insight[insight_field].to_f if Insight::DECIMAL_ATTRIBUTES.include?(insight_field)

        insight[insight_field].to_i
      end

      def premium
        @insightable.premium?
      end

      def insight_ratio
        @insight_ratio ||= premium && @insightable.configuration.insight_ratio
      end
    end
  end
end
