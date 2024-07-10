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
        data = []
        data << ['', 'Developer', *headers_data(insight_fields)]

        insights.each do |insight|
          data << [
            { image: URI.open(insight.dig('entity', 'avatar_url')), image_height: 12, image_width: 12 },
            insight.dig('entity', 'login'),
            *insight_data(insight['values'].symbolize_keys, insight_fields)
          ]
        end

        table(
          data,
          header: true,
          row_colors: %w[ffffff f3f4f6],
          cell_style: {
            border_width: 1,
            border_color: 'e5e7eb'
          }
        )

        render
      end

      private

      def headers_data(insight_fields)
        insight_fields.map { |insight_field| Insight::SHORT_ATTRIBUTE_NAMES[insight_field] }
      end

      def insight_data(values, insight_fields)
        insight_fields.map { |insight_field| values.dig(insight_field, 'value') }
      end
    end
  end
end
