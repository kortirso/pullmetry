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

      def insight_fields
        @insight_fields ||=
          if @insightable.premium? && @insightable.configuration.insight_fields.present?
            @insightable.configuration.insight_fields.attributes.filter_map { |key, value| value ? key.to_sym : nil }
          else
            Insight::DEFAULT_ATTRIBUTES
          end
      end
    end
  end
end
