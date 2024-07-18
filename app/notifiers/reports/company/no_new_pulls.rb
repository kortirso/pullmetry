# frozen_string_literal: true

module Reports
  module Company
    class NoNewPulls
      THREE_WORK_DAYS_IN_SECONDS = 86_400

      private

      def title(insightable)
        "No new pulls report for #{insightable.class.name.downcase} #{insightable.title}"
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
          .where('time_since_last_open_pull_seconds > ?', THREE_WORK_DAYS_IN_SECONDS)
          .joins(:entity)
          .hashable_pluck(
            :time_since_last_open_pull_seconds,
            'entities.login',
            'entities.avatar_url'
          )
      end
    end
  end
end
