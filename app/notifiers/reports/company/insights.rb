# frozen_string_literal: true

module Reports
  module Company
    class Insights
      private

      def title(insightable)
        "Pull review insights of #{insightable.class.name.downcase} #{insightable.title}"
      end

      def accessable_message(insightable)
        return '' if insightable.accessable?

        "#{insightable.class.name} #{insightable.title} has access error"
      end

      def insights_data(insightable)
        visible_insights(insightable).map { |insight| insight_data(insight) }
      end

      def visible_insights(insightable)
        ::Insights::VisibleQuery
          .new(relation: insightable.insights)
          .resolve(insightable: insightable)
          .actual
          .joins(:entity)
          .hashable_pluck(
            :comments_count,
            :reviews_count,
            :average_review_seconds,
            'entities.login',
            'entities.avatar_url'
          )
      end
    end
  end
end
