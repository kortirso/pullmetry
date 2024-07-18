# frozen_string_literal: true

module Reports
  module Company
    module Custom
      class NoNewPulls < Reports::Company::NoNewPulls
        def call(insightable:)
          {
            title: title(insightable),
            accessable: accessable_message(insightable),
            insights: insights_data(insightable)
          }
        end

        private

        def insight_data(insight)
          {
            entity: insight[:entities_login],
            avatar_url: insight[:entities_avatar_url],
            time_since_last_open_pull_seconds: insight[:time_since_last_open_pull_seconds].to_i
          }
        end
      end
    end
  end
end
