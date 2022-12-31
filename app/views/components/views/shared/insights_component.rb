# frozen_string_literal: true

module Views
  module Shared
    class InsightsComponent < ApplicationViewComponent
      def initialize(insightable:)
        @insightable = insightable

        super()
      end
    end
  end
end
