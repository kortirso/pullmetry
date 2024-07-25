# frozen_string_literal: true

module Reports
  module Insights
    class Pdf < Prawn::Document
      PAGE_SIZE = 'A4'
      PAGE_LAYOUT = :landscape

      def to_pdf(insightable:, insights:, insight_fields:)
        text(
          [
            'Insights report',
            "#{insightable.class.name.downcase} #{insightable.title}",
            current_time
          ].join(', ')
        )
        move_down(18)

        font 'Courier', size: 7
        headers_data = ['', *render_headers_data(insight_fields)]
        insights.map! { |insight| render_insight(insight, insight_fields) }

        table(
          [
            headers_data,
            *insights
          ],
          **table_options
        )

        render
      end

      private

      def current_time
        "#{DateTime.now.utc.strftime('%Y.%m.%d %H:%M')} UTC"
      end

      def render_headers_data(insight_fields)
        insight_fields.map { |insight_field| Insight::SHORT_ATTRIBUTE_NAMES[insight_field] }
      end

      def render_insight(insight, insight_fields)
        [
          insight.dig('entity', 'login'),
          *render_insight_values(insight['values'].symbolize_keys, insight_fields)
        ]
      end

      def render_insight_values(values, insight_fields)
        insight_fields.map do |insight_field|
          value = values.dig(insight_field, 'value')
          next "#{value}%" if Insight::PERCENTILE_ATTRIBUTES.include?(insight_field)
          next time_representer.call(value: value.to_i) if Insight::TIME_ATTRIBUTES.include?(insight_field)

          value
        end
      end

      def table_options
        {
          header: true,
          row_colors: %w[ffffff f3f4f6],
          cell_style: {
            border_width: 1,
            border_color: 'e5e7eb'
          }
        }
      end

      def time_representer = ::Pullmetry::Container['services.converters.seconds_to_text']
    end
  end
end
