# frozen_string_literal: true

module Reports
  module Company
    module Discord
      class Insights < Reports::Company::Insights
        include Deps[time_representer: 'services.converters.seconds_to_text']

        def call(insightable:)
          [
            "**#{title(insightable)}**",
            "**#{accessable_message(insightable)}**",
            insights_data(insightable),
            footer_block
          ].join("\n")
        end

        private

        def insight_data(insight)
          average_time = time_representer.call(value: insight[:average_review_seconds].to_i)
          [
            insight[:entities_login],
            [
              "**Total comments:** #{insight[:comments_count].to_i}",
              "**Total reviews:** #{insight[:reviews_count].to_i}",
              "**Average review time:** #{average_time}"
            ].join(', ')
          ].join("\n")
        end

        def footer_block
          "\nTo check up-to-date statistics please visit <https://pullkeeper.dev>"
        end
      end
    end
  end
end
