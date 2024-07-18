# frozen_string_literal: true

module Reports
  module Company
    module Discord
      class NoNewPulls < Reports::Company::NoNewPulls
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
          time = time_representer.call(value: insight[:time_since_last_open_pull_seconds].to_i)
          [
            insight[:entities_login],
            "**Time since last open pull request:** #{time}"
          ].join("\n")
        end

        def footer_block
          "\nTo check up-to-date statistics please visit <https://pullkeeper.dev>"
        end
      end
    end
  end
end
