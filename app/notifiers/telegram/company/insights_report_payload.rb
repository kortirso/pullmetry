# frozen_string_literal: true

module Telegram
  module Company
    class InsightsReportPayload
      include Deps[time_representer: 'services.converters.seconds_to_text']

      def call(insightable:)
        title(insightable) + accessable_message(insightable) + insights(insightable)
      end

      private

      def title(insightable)
        "Pull review insights of #{insightable.class.name.downcase} #{insightable.title}\n"
      end

      def accessable_message(insightable)
        return "\n" if insightable.accessable?

        "#{insightable.class.name} #{insightable.title} has access error\n\n"
      end

      def insights(insightable)
        visible_insights(insightable).map { |insight|
          "#{insight[:entities_login]} #{insight_data(insight)}"
        }.join("\n")
      end

      def visible_insights(insightable)
        ::Insights::VisibleQuery
          .new(relation: insightable.insights)
          .resolve(insightable: insightable)
          .actual
          .joins(:entity)
          .hashable_pluck(:comments_count, :reviews_count, :average_review_seconds, 'entities.login')
      end

      # rubocop: disable Layout/LineLength
      def insight_data(insight)
        average_time = time_representer.call(value: insight[:average_review_seconds].to_i)
        "Total comments: #{insight[:comments_count].to_i}, Total reviews: #{insight[:reviews_count].to_i}, Average review time: #{average_time}"
      end
      # rubocop: enable Layout/LineLength
    end
  end
end
