# frozen_string_literal: true

module Webhooks
  module Insight
    class ReportPayload
      def call(insightable:)
        {
          title: title(insightable),
          accessable: accessable_message(insightable),
          insights: insights(insightable)
        }
      end

      private

      def title(insightable)
        "Pull review insights of #{insightable.class.name.downcase} #{insightable.title}"
      end

      def accessable_message(insightable)
        return '' if insightable.accessable?

        "#{insightable.class.name} #{insightable.title} has access error"
      end

      def insights(insightable)
        visible_insights(insightable).map { |insight|
          {
            entity: insight[:entities_login],
            comments_count: insight[:comments_count].to_i,
            reviews_count: insight[:reviews_count].to_i,
            average_review_seconds: insight[:average_review_seconds].to_i
          }
        }
      end

      def visible_insights(insightable)
        ::Insights::VisibleQuery
          .new(relation: insightable.insights)
          .resolve(insightable: insightable)
          .actual
          .joins(:entity)
          .hashable_pluck(:comments_count, :reviews_count, :average_review_seconds, 'entities.login')
      end
    end
  end
end
