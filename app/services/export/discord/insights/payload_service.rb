# frozen_string_literal: true

module Export
  module Discord
    module Insights
      class PayloadService
        prepend ApplicationService

        def initialize(time_representer: Converters::SecondsToTextService.new)
          @time_representer = time_representer
        end

        def call(insightable:)
          @insightable = insightable
          @result = header_block + accessable_message + insights_blocks + footer_block
        end

        private

        def header_block
          "**Pull review insights of #{@insightable.class.name.downcase} #{@insightable.title}**\n"
        end

        def accessable_message
          return '' if @insightable.accessable?

          "**#{@insightable.class.name} #{@insightable.title} has access error**\n"
        end

        def insights_blocks
          visible_insights.map { |insight|
            "#{insight[:entities_login]} #{insight_data(insight)}"
          }.join("\n")
        end

        def visible_insights
          ::Insights::VisibleQuery
            .new(relation: @insightable.insights)
            .resolve(insightable: @insightable)
            .actual
            .joins(:entity)
            .hashable_pluck(:comments_count, :reviews_count, :average_review_seconds, 'entities.login')
        end

        def footer_block
          "\nTo check up-to-date statistics please visit <https://pullkeeper.dev>"
        end

        # rubocop: disable Layout/LineLength
        def insight_data(insight)
          average_time = @time_representer.call(value: insight[:average_review_seconds].to_i)
          "**Total comments:** #{insight[:comments_count].to_i}, **Total reviews:** #{insight[:reviews_count].to_i}, **Average review time:** #{average_time}"
        end
        # rubocop: enable Layout/LineLength
      end
    end
  end
end
