# frozen_string_literal: true

module Insights
  class VisibleQuery < ApplicationQuery
    def initialize(relation: Insight.none) = super

    # response contains actual and previous scopes
    def resolve(insightable:)
      order_by = insightable.current_config.main_attribute
      relation
        .where('reviews_count > 0 OR comments_count > 0 OR open_pull_requests_count > 0')
        .order(order_by => (Insight::REVERSE_ORDER_ATTRIBUTES.include?(order_by) ? :asc : :desc))
    end
  end
end
