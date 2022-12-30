# frozen_string_literal: true

module Import
  module Representers
    class Comments
      def initialize(entity_representer: Entity.new)
        @entity_representer = entity_representer
      end

      def call(data:)
        data.map do |payload|
          payload = payload.with_indifferent_access
          {
            external_id: payload[:id],
            comment_created_at: payload[:created_at],
            author: @entity_representer.call(data: payload[:user])
          }
        end
      end
    end
  end
end
