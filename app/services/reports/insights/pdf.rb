# frozen_string_literal: true

module Reports
  module Insights
    class Pdf < Prawn::Document
      PAGE_SIZE = 'A4'
      PAGE_LAYOUT = :landscape

      def to_pdf(insights:, insight_fields:)
        text 'Insights report'
        move_down(18)

        font 'Courier', size: 8
        headers_data = ['', 'Developer', *render_headers_data(insight_fields)]
        insights.map! { |insight| render_insight(insight, insight_fields) }

        table(
          [
            headers_data + insights
          ],
          **table_options
        )

        render
      end

      private

      def render_headers_data(insight_fields)
        insight_fields.map { |insight_field| Insight::SHORT_ATTRIBUTE_NAMES[insight_field] }
      end

      def render_insight(insight, insight_fields)
        [
          {
            image: URI.parse(insight.dig('entity', 'avatar_url')).open, image_height: 12, image_width: 12
          },
          insight.dig('entity', 'login'),
          *render_insight_values(insight['values'].symbolize_keys, insight_fields)
        ]
      end

      def render_insight_values(values, insight_fields)
        insight_fields.map { |insight_field| values.dig(insight_field, 'value') }
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
    end
  end
end
