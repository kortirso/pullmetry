# frozen_string_literal: true

module Frontend
  class InsightsController < Frontend::BaseController
    before_action :find_insightable

    def index
      respond_to do |format|
        format.json { render json: Panko::Response.new(json_response), status: :ok }
        format.pdf { send_data pdf_response, type: 'application/pdf', filename: 'insights.pdf' }
      end
    end

    private

    def json_response
      {
        insights: insights,
        insight_fields: insight_fields,
        ratio_type: ratio_enabled? ? ratio_type : nil
      }
    end

    def pdf_response
      Reports::Insights::Pdf.new(
        page_size: Reports::Insights::Pdf::PAGE_SIZE,
        page_layout: Reports::Insights::Pdf::PAGE_LAYOUT
      ).to_pdf(
        insightable: @insightable,
        insights: JSON.parse(insights.to_json),
        insight_fields: insight_fields
      )
    end

    def insights
      Panko::ArraySerializer.new(
        actual_insights,
        each_serializer: InsightSerializer,
        only: %i[id values entity],
        context: {
          previous_insights: previous_insights,
          insight_fields: insight_fields,
          ratio_enabled: ratio_enabled?,
          ratio_type: ratio_type
        }
      )
    end

    def find_insightable
      find_company if params[:company_id]
      find_repository if params[:repository_id]

      page_not_found unless @insightable
    end

    def find_company
      @insightable = authorized_scope(Company.order(created_at: :desc)).find_by(id: params[:company_id])
    end

    def find_repository
      @insightable = authorized_scope(Repository.order(created_at: :desc)).find_by(id: params[:repository_id])
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
      current_config.selected_insight_fields
    end

    def ratio_enabled?
      current_config.insight_ratio
    end

    def ratio_type
      current_config.insight_ratio_type
    end

    def current_config
      @current_config ||= @insightable.current_config
    end
  end
end
