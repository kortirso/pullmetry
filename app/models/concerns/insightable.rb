# frozen_string_literal: true

module Insightable
  extend ActiveSupport::Concern

  included do
    has_many :insights, as: :insightable, dependent: :destroy
  end

  def sorted_insights
    main_attribute = premium? ? configuration.main_attribute : :comments_count

    insights
      .where('reviews_count IS NOT NULL AND reviews_count > 0')
      .includes(:entity)
      .order(main_attribute => (main_attribute.ends_with?('seconds') ? :asc : :desc))
  end
end
