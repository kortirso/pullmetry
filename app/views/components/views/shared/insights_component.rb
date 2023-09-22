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

      def repository_insights
        @repository_insights ||= @insightable.repository_insights.to_a
      end

      def actual_repository_insight
        @actual_repository_insight ||= repository_insights.find(&:actual?)
      end

      def previous_repository_insight
        @previous_repository_insight ||= repository_insights.reject(&:actual?).first
      end

      # rubocop: disable Rails/OutputSafety
      def render_repository_insight(attribute)
        result = convert_repository_insight_field(actual_repository_insight, attribute).to_s
        result += repository_insight_ratio_value(actual_repository_insight, attribute) if @insight_ratio
        result.html_safe
      end
      # rubocop: enable Rails/OutputSafety

      private

      def convert_repository_insight_field(insight, insight_field)
        return convert_seconds(insight[insight_field]) if Repositories::Insight::TIME_ATTRIBUTES.include?(insight_field)
        return insight[insight_field].to_f if Repositories::Insight::DECIMAL_ATTRIBUTES.include?(insight_field)

        insight[insight_field].to_i
      end

      def convert_seconds(value)
        @seconds_converter.call(value: value)
      end

      # TODO: refactoring is required
      # rubocop: disable Layout/LineLength, Metrics/AbcSize
      def repository_insight_ratio_value(insight, attribute)
        return '' if insight[attribute].nil?

        time_attribute = Repositories::Insight::TIME_ATTRIBUTES.include?(attribute)
        reverse_attribute = Repositories::Insight::REVERSE_ORDER_ATTRIBUTES.include?(attribute)
        change_type = @insightable.configuration.insight_ratio_type == 'change'

        ratio_value = change_type ? change_value(insight, previous_repository_insight, attribute) : ratio_value(insight, previous_repository_insight, attribute)

        value = multiple_value(ratio_value, reverse_attribute, change_type)
        value_for_rendering = time_attribute && change_type ? convert_seconds(value.abs) : value.abs

        "<sup class='#{span_class(ratio_value, reverse_attribute)}'>#{value_sign(value, reverse_attribute)}#{value_for_rendering}#{change_type ? '' : '%'}</sup>"
      end
      # rubocop: enable Layout/LineLength, Metrics/AbcSize

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
        return '+' if (value.positive? && !reverse_attribute) || (value.negative? && reverse_attribute)

        '-'
      end

      def ratio_value(insight, previous_insight, attribute)
        return 0 if previous_insight.nil?

        previous_period = previous_insight[attribute].to_f
        return 0 if previous_period.zero?

        ((insight[attribute].to_f - previous_period) * 100 / previous_period).to_i
      end

      def change_value(insight, previous_insight, insight_field)
        method_name = insight_field == 'average_open_pr_comments' ? :to_f : :to_i
        return insight[attribute].send(method_name) if previous_insight.nil?

        insight[attribute].send(method_name) - previous_insight[insight_field].send(method_name)
      end
    end
  end
end
