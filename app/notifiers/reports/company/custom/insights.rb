# frozen_string_literal: true

module Reports
  module Company
    module Custom
      class Insights < Reports::Company::Insights
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
            comments_count: insight[:comments_count].to_i,
            reviews_count: insight[:reviews_count].to_i,
            average_review_seconds: insight[:average_review_seconds].to_i
          }
        end
      end
    end
  end
end
