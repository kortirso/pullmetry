# frozen_string_literal: true

module Frontend
  module Repositories
    class RepositoryInsightsController < Frontend::BaseController
      before_action :find_repository

      def index
        render json: Panko::Response.create { |response| json_response(response) }, status: :ok
      end

      private

      def json_response(response)
        insight = actual_insight
        return { insight: nil, ratio_type: nil } if insight.nil?

        {
          insight: response.serializer(
            insight,
            InsightSerializer,
            only: %i[id values entity],
            context: {
              previous_insights: previous_insights,
              insight_fields: ::Repositories::Insight::DEFAULT_ATTRIBUTES,
              ratio_enabled: ratio_enabled?,
              ratio_type: ratio_type,
              no_entity: true
            }
          ),
          ratio_type: ratio_enabled? ? ratio_type : nil
        }
      end

      def find_repository
        @repository = authorized_scope(Repository.order(created_at: :desc)).find(params[:repository_id])
      end

      def visible_insights
        @visible_insights ||= @repository.repository_insights.to_a
      end

      def actual_insight
        visible_insights.find(&:actual?)
      end

      def previous_insights
        visible_insights.reject(&:actual?).first
      end

      def ratio_enabled?
        current_config.insight_ratio
      end

      def ratio_type
        current_config.insight_ratio_type
      end

      def current_config
        @current_config ||= @repository.current_config
      end
    end
  end
end
