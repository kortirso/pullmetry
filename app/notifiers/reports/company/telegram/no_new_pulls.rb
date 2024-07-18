# frozen_string_literal: true

module Reports
  module Company
    module Telegram
      class NoNewPulls < Reports::Company::NoNewPulls
        include Deps[time_representer: 'services.converters.seconds_to_text']

        def call(insightable:)
          [
            title(insightable),
            accessable_message(insightable),
            insights_data(insightable)
          ].join("\n")
        end

        private

        def insight_data(insight)
          time = time_representer.call(value: insight[:time_since_last_open_pull_seconds].to_i)
          [
            insight[:entities_login],
            "Time since last open pull request: #{time}"
          ].join("\n")
        end
      end
    end
  end
end
