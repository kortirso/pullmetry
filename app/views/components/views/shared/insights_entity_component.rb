# frozen_string_literal: true

module Views
  module Shared
    class InsightsEntityComponent < ApplicationViewComponent
      def initialize(entity_id:)
        @entity = Rails.cache.read("entity_payload_#{entity_id}_v1") || Entity::EMPTY_PAYLOAD

        super()
      end
    end
  end
end
