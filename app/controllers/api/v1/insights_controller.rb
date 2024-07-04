# frozen_string_literal: true

module Api
  module V1
    class InsightsController < Api::V1Controller
      before_action :find_insightable

      def index
        render json: {
          insights: InsightSerializer.new(
            actual_insights,
            {
              params: {
                previous_insights: previous_insights,
                insight_fields: insight_fields,
                ratio_enabled: ratio_enabled?,
                ratio_type: ratio_type
              }
            }
          ).serializable_hash,
          ratio_type: ratio_enabled? ? ratio_type : nil
        }.compact, status: :ok
      end

      private

      def find_insightable
        find_company if params[:company_id]
        find_repository if params[:repository_id]

        page_not_found unless @insightable
      end

      def find_company
        @insightable = authorized_scope(Company.order(id: :desc)).find_by(uuid: params[:company_id])
      end

      def find_repository
        @insightable = authorized_scope(Repository.order(id: :desc)).find_by(uuid: params[:repository_id])
      end

      def visible_insights
        @visible_insights ||=
          Insights::VisibleQuery
            .new(relation: @insightable.insights)
            .resolve(insightable: @insightable)
            .load
      end

      def actual_insights
        visible_insights.select(&:actual?)
      end

      def previous_insights
        visible_insights.reject(&:actual?)
      end

      def insight_fields
        if @insightable.premium? && @insightable.configuration.insight_fields.present?
          @insightable.selected_insight_fields
        else
          Insight::DEFAULT_ATTRIBUTES
        end
      end

      def ratio_enabled?
        @insightable.premium? && @insightable.configuration.insight_ratio
      end

      def ratio_type
        @insightable.configuration.insight_ratio_type
      end
    end
  end
end
