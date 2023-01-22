# frozen_string_literal: true

module Views
  module Shared
    class InsightsComponent < ApplicationViewComponent
      SECONDS_IN_MINUTE = 60
      SECONDS_IN_HOUR = 3_600
      SECONDS_IN_DAY = 86_400
      MINUTES_IN_HOUR = 60
      HOURS_IN_DAY = 24

      def initialize(insightable:)
        @insightable = insightable
        @access_token = insightable.access_token
        @insights = insightable.insights

        super()
      end

      def convert_seconds(value)
        return '-' if value.to_i.zero?
        return '1m' if value < SECONDS_IN_MINUTE

        minutes = (value / SECONDS_IN_MINUTE) % MINUTES_IN_HOUR
        return "#{minutes}m" if value < SECONDS_IN_HOUR

        hours = (value / SECONDS_IN_HOUR) % HOURS_IN_DAY
        return "#{hours}h #{minutes}m" if value < SECONDS_IN_DAY

        "#{value / SECONDS_IN_DAY}d #{hours}h #{minutes}m"
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

      def premium
        @insightable.premium?
      end

      def insight_ratio
        @insight_ratio ||= premium && @insightable.configuration.insight_ratio
      end
    end
  end
end
