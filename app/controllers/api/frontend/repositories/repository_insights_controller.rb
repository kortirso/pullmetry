# frozen_string_literal: true

module Api
  module Frontend
    module Repositories
      class RepositoryInsightsController < Api::Frontend::BaseController
        before_action :find_repository

        def index
          render json: {
            insights: InsightSerializer.new(
              actual_insights,
              {
                params: {
                  previous_insights: previous_insights,
                  insight_fields: ::Repositories::Insight::DEFAULT_ATTRIBUTES,
                  ratio_enabled: ratio_enabled?,
                  ratio_type: ratio_type,
                  no_entity: true
                }
              }
            ).serializable_hash,
            ratio_type: ratio_enabled? ? ratio_type : nil
          }.compact, status: :ok
        end

        private

        def find_repository
          @repository = authorized_scope(Repository.order(id: :desc)).find_by!(uuid: params[:repository_id])
        end

        def visible_insights
          @visible_insights ||= @repository.repository_insights.to_a
        end

        def actual_insights
          visible_insights.find(&:actual?)
        end

        def previous_insights
          visible_insights.reject(&:actual?).first
        end

        def ratio_enabled?
          @repository.premium? && @repository.configuration.insight_ratio
        end

        def ratio_type
          @repository.configuration.insight_ratio_type
        end
      end
    end
  end
end
