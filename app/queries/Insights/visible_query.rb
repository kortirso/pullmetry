# frozen_string_literal: true

module Insights
  class VisibleQuery < ApplicationQuery
    def initialize(relation: Insight.all) = super

    # response contains actual and previous scopes
    def resolve(insightable:)
      order_by = insightable.premium? ? insightable.configuration.main_attribute : Insight::DEFAULT_ORDER_ATTRIBUTE

      relation
        .where('reviews_count > 0 OR comments_count > 0 OR open_pull_requests_count > 0')
        .order(order_by => (Insight::REVERSE_ORDER_ATTRIBUTES.include?(order_by) ? :asc : :desc))
    end
  end
end
